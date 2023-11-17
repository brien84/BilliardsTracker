//
//  Main.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-23.
//

import ComposableArchitecture
import SwiftUI

struct Main: ReducerProtocol {
    struct State: Equatable {
        var drillList = DrillList.State()
        var drillLog: DrillLog.State?
        var newDrill = NewDrill.State()
        var session: Session.State?
        var settings = Settings.State()

        var alert: AlertState<Action>?

        var isShowingLoadingIndicator = false

        @BindingState var isNavigationToDrillLogActive = false
        @BindingState var isNavigationToNewDrillActive = false
        @BindingState var isNavigationToSessionActive = false
        @BindingState var isNavigationToOnboardActive = false
    }

    enum Action: BindableAction, Equatable {
        case drillList(DrillList.Action)
        case drillLog(DrillLog.Action)
        case newDrill(NewDrill.Action)
        case session(Session.Action)
        case settings(Settings.Action)

        case alertDidDismiss
        case binding(BindingAction<State>)
        case didDismissOnboardView
        case onAppear

        case connectivityClientDidReceiveResult(ResultContext)
        case connectivityClientDidReceiveResponse(ConnectivityResponse)

        case persistenceClient(PersistenceResponse)
    }

    @Dependency(\.connectivityClient) var connectivityClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.userDefaults) var userDefaults

    @Dependency(\.date.now) var now
    @Dependency(\.mainQueue) var mainQueue

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.newDrill, action: /Action.newDrill) {
            NewDrill()
        }

        Scope(state: \.settings, action: /Action.settings) {
            Settings()
        }

        Reduce { state, action in
            switch action {
            case .drillList(.didTapNewDrillButton):
                state.newDrill = NewDrill.State()
                state.isNavigationToNewDrillActive = true
                return .none

            case .drillList(.drillItem(id: let id, action: .didSelectDrill)):
                if let drill = state.drillList.drillItems[id: id]?.drill {
                    state.isShowingLoadingIndicator = true
                    state.session = Session.State(drill: drill, startDate: now)
                    let context = DrillContext(
                        isActive: true,
                        isContinuous: drill.isContinuous,
                        shotCount: drill.shotCount,
                        title: drill.title
                    )
                    return .task {
                        try await mainQueue.sleep(for: .milliseconds(500))
                        return .connectivityClientDidReceiveResponse(
                            await connectivityClient.sendDrillContext(context)
                        )
                    }
                } else {
                    return .none
                }

            case .drillList(.drillItem(id: let id, action: .didPressDrillLogButton)):
                if let drill = state.drillList.drillItems[id: id]?.drill {
                    state.drillLog = DrillLog.State(drill: drill)
                    state.isNavigationToDrillLogActive = true
                }
                return .none

            case .drillLog(.didDeleteDrill):
                guard let drill = state.drillLog?.drill else { return .none }
                state.isNavigationToDrillLogActive = false
                return .task {
                    .persistenceClient(await persistenceClient.deleteDrill(drill))
                }

            case .drillLog:
                return .none

            case .newDrill(.cancelButtonDidTap):
                state.isNavigationToNewDrillActive = false
                return .none

            case .newDrill(.saveButtonDidTap):
                state.isNavigationToNewDrillActive = false
                let drill = Drill(entity: Drill.entity(), insertInto: nil)
                drill.shotCount = state.newDrill.shotCount
                drill.isContinuous = state.newDrill.isContinuous
                drill.title = state.newDrill.title.isEmpty ? "Drill Title" : state.newDrill.title
                return .task {
                    .persistenceClient(await persistenceClient.createDrill(drill))
                }

            case .newDrill:
                return .none

            case .session(.sessionDidExit):
                state.isNavigationToSessionActive = false
                return .fireAndForget {
                    let context = DrillContext(isActive: false, isContinuous: false, shotCount: 0, title: "")
                    _ = await connectivityClient.sendDrillContext(context)
                }

            case .session:
                return .none

            case .settings(.didSelectSortOption), .settings(.didSelectSortOrder):
                let drills = state.drillList.drillItems.map { $0.drill }
                let sortedDrills = drills.sorted(using: state.settings.sortDescriptor)
                state.drillList = DrillList.State(drills: sortedDrills)
                return .none

            case .settings(.didSelectAppearance(let appearance)):
                setAlertAppearance(appearance)
                return .none

            case .alertDidDismiss:
                if state.alert == initializationAlert {
                    fatalError()
                }
                state.alert = nil
                return .none

            case .binding(\.$isNavigationToNewDrillActive):
                if state.isNavigationToNewDrillActive {
                    state.newDrill = NewDrill.State()
                }
                return .none

            case .didDismissOnboardView:
                state.isNavigationToOnboardActive = false
                return .fireAndForget {
                    await userDefaults.setHasOnboardBeenShown(true)
                }

            case .binding:
                return .none

            case .onAppear:
                state.isShowingLoadingIndicator = true
                state.isNavigationToOnboardActive = !userDefaults.getHasOnboardBeenShown()
                state.settings = Settings.State(
                    appearance: userDefaults.getAppearance(),
                    sortOption: userDefaults.getSortOption(),
                    sortOrder: userDefaults.getSortOrder()
                )
                setAlertAppearance(state.settings.appearance)
                return .merge(
                    .fireAndForget {
                        await userDefaults.setAppVersion()
                    },
                    .task {
                        try await mainQueue.sleep(for: .milliseconds(250))
                        return .persistenceClient(await persistenceClient.loadDrills())
                    }.animation(),
                    .run { send in
                        for await result in await connectivityClient.receiveResults() {
                            await send(.connectivityClientDidReceiveResult(result))
                        }
                    }
                )

            case .connectivityClientDidReceiveResponse(let response):
                state.isShowingLoadingIndicator = false

                switch response {
                case .success:
                    state.isNavigationToSessionActive = true

                case .failure(.notReachable):
                    state.alert = notReachableAlert

                case .failure(.notReady):
                    state.alert = notReadyAlert
                }

                return .none

            case .connectivityClientDidReceiveResult(let result):
                guard state.isNavigationToSessionActive else { return .none }
                guard let drill = state.session?.drill else { return .none }
                return .task {
                    .persistenceClient(await persistenceClient.insertResult(result, drill))
                }

            case .persistenceClient(let response):
                switch response {
                case .didSucceed:
                    return .task {
                        .persistenceClient(await persistenceClient.loadDrills())
                    }.animation()

                case .didLoad(let drills):
                    state.isShowingLoadingIndicator = false
                    let drills = drills.sorted(using: state.settings.sortDescriptor)
                    state.drillList = DrillList.State(drills: drills)

                    if let session = state.session {
                        state.session = Session.State(drill: session.drill, startDate: session.startDate)
                    }

                    return .none

                case .didFail(.initialization):
                    state.alert = initializationAlert
                    return .none

                case .didFail(.loading):
                    state.alert = loadingAlert
                    return .none

                case .didFail(.saving):
                    state.alert = savingAlert
                    return .none
                }
            }
        }
        .ifLet(\.session, action: /Action.session) {
            Session()
        }
        .ifLet(\.drillLog, action: /Action.drillLog) {
            DrillLog()
        }
    }
}
