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
        var newDrill = NewDrill.State()
        var session: Session.State?
        var settings = Settings.State()
        var statistics: Statistics.State?

        var alert: AlertState<Action>?

        var isShowingLoadingIndicator = false

        @BindingState var isNavigationToNewDrillActive = false
        @BindingState var isNavigationToSessionActive = false
        @BindingState var isNavigationToStatisticsActive = false
    }

    enum Action: BindableAction, Equatable {
        case drillList(DrillList.Action)
        case newDrill(NewDrill.Action)
        case session(Session.Action)
        case settings(Settings.Action)
        case statistics(Statistics.Action)

        case alertDidDismiss
        case binding(BindingAction<State>)
        case onAppear

        case connectivityClientDidReceiveResult(ResultContext)
        case connectivityClientDidReceiveResponse(ConnectivityResponse)

        case persistenceClient(PersistenceResponse)
    }

    @Dependency(\.connectivityClient) var connectivityClient
    @Dependency(\.persistenceClient) var persistenceClient

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

            case .drillList(.drillItem(id: let id, action: .didTapStatisticsButton)):
                if let drill = state.drillList.drillItems[id: id]?.drill {
                    state.statistics = Statistics.State(drill: drill)
                    state.isNavigationToStatisticsActive = true
                }
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

            case .session(.didTapExitButton):
                state.isNavigationToSessionActive = false
                return .fireAndForget {
                    let context = DrillContext(isActive: false, isContinuous: false, shotCount: 0, title: "")
                    _ = await connectivityClient.sendDrillContext(context)
                }

            case .settings(.didSelectSortOption), .settings(.didSelectSortOrder):
                let drills = state.drillList.drillItems.map { $0.drill }
                let sortedDrills = drills.sorted(using: state.settings.sortDescriptor)
                state.drillList = DrillList.State(drills: sortedDrills)
                return .none

            case .statistics(.didTapDeleteButton):
                guard let drill = state.statistics?.drill else { return .none }
                state.isNavigationToStatisticsActive = false
                return .task {
                    .persistenceClient(await persistenceClient.deleteDrill(drill))
                }

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

            case .binding:
                return .none

            case .onAppear:
                state.isShowingLoadingIndicator = true
                return .merge(
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
        .ifLet(\.statistics, action: /Action.statistics) {
            Statistics()
        }
    }
}

// MARK: - Alerts

private extension Main {

    var initializationAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Something went terribly wrong!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
        }
    }

    var loadingAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Something went wrong!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
        }
    }

    var notReachableAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Watch app is not reachable!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Make sure BilliardsTracker Watch app is installed and running.")
        }
    }

    var notReadyAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Watch app is not in Tracked mode!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Make sure Tracked mode is selected in Watch app.")
        }
    }

    var savingAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Something went wrong!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Latest changes will not be saved.")
        }
    }

}
