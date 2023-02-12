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

        var isNavigationToStatisticsActive: Bool {
            statistics != nil
        }

        var isShowingLoadingIndicator = false

        @BindingState var isNavigationToNewDrillActive = false
        @BindingState var isNavigationToSessionActive = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case newDrill(NewDrill.Action)
        case drillList(DrillList.Action)
        case session(Session.Action)
        case settings(Settings.Action)
        case statistics(Statistics.Action)

        case alertDidDismiss

        case setNavigationToStatistics(isActive: Bool)

        case beginReceivingResults
        case connectivityClientDidReceiveResult(ResultContext)
        case connectivityClientDidReceiveResponse(ConnectivityResponse)

        case loadDrills
        case persistenceClientDidLoad(TaskResult<[Drill]>)
        case persistenceClient(PersistenceResponse)
    }

    @Dependency(\.connectivityClient) var connectivityClient
    @Dependency(\.persistenceClient) var persistenceClient

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

            case .binding(\.$isNavigationToNewDrillActive):
                if state.isNavigationToNewDrillActive {
                    state.newDrill = NewDrill.State()
                }
                return .none

            case .binding:
                return .none

            case .newDrill(.cancelButtonDidTap):
                state.isNavigationToNewDrillActive = false
                return .none

            case .newDrill(.saveButtonDidTap):
                state.isNavigationToNewDrillActive = false
                let drill = Drill(entity: Drill.entity(), insertInto: nil)
                drill.attempts = state.newDrill.attempts
                drill.isContinuous = state.newDrill.isContinuous
                drill.title = state.newDrill.title.isEmpty ? "Drill Title" : drill.title
                return .task {
                    .persistenceClient(await persistenceClient.createDrill(drill))
                }

            case .newDrill:
                return .none

            case .drillList(.drillItem(id: let id, action: .didSelectDrill)):
                if let drill = state.drillList.drillItems[id: id]?.drill {
                    state.isShowingLoadingIndicator = true
                    state.session = Session.State(drill: drill, startDate: Date())
                    let context = DrillContext(
                        isActive: true,
                        attempts: drill.attempts,
                        isContinuous: drill.isContinuous,
                        title: drill.title
                    )
                    return .task {
                        .connectivityClientDidReceiveResponse(
                            await connectivityClient.sendDrillContext(context)
                        )
                    }
                } else {
                    return .none
                }

            case .drillList(.drillItem(id: let id, action: .didTapStatisticsButton)):
                if let drill = state.drillList.drillItems[id: id]?.drill {
                    state.statistics = Statistics.State(drill: drill)
                }
                return .none

            case .session(.didTapExitButton):
                state.isNavigationToSessionActive = false
                return .fireAndForget {
                    let context = DrillContext(isActive: false, attempts: 0, isContinuous: false, title: "")
                    _ = await connectivityClient.sendDrillContext(context)
                }

            case .settings(.didSelectSortOption):
                let drills = state.drillList.drillItems.map { $0.drill }.sorted {
                    switch state.settings.sortOption {
                    case .attempts:
                        return $0.attempts < $1.attempts
                    case .dateCreated:
                        return $0.dateCreated < $1.dateCreated
                    case .title:
                        return $0.title < $1.title
                    }
                }

                state.drillList = DrillList.State(drills: drills)

                return .none

            case .statistics(.didTapDeleteButton):
                guard let drill = state.statistics?.drill else { return .none }
                return .task {
                    .persistenceClient(await persistenceClient.deleteDrill(drill))
                }

            case .beginReceivingResults:
                return .run { send in
                    for await result in await connectivityClient.receiveResults() {
                        await send(.connectivityClientDidReceiveResult(result))
                    }
                }

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

            case .alertDidDismiss:
                if state.alert == initializationAlert {
                    fatalError()
                }
                state.alert = nil
                return .none

            case .persistenceClient(let response):
                switch response {
                case .success:
                    return .task {
                        await .persistenceClientDidLoad(
                            TaskResult { try await persistenceClient.loadDrills() }
                        )
                    }.animation()

                case .failure(.saving):
                    state.alert = savingAlert
                    return .none

                case .failure(.initialization):
                    state.alert = initializationAlert
                    return .none

                case .failure:
                    return .none
                }

            case .persistenceClientDidLoad(let result):
                switch result {
                case .success(let drills):
                    let drills = drills.sorted {
                        switch state.settings.sortOption {
                        case .attempts:
                            return $0.attempts < $1.attempts
                        case .dateCreated:
                            return $0.dateCreated < $1.dateCreated
                        case .title:
                            return $0.title < $1.title
                        }
                    }

                    state.drillList = DrillList.State(drills: drills)

                    if let session = state.session {
                        state.session = Session.State(drill: session.drill, startDate: session.startDate)
                    }

                    return .none

                case .failure(let error):
                    switch error {
                    case PersistenceResponse.Failure.initialization:
                        state.alert = initializationAlert
                    case PersistenceResponse.Failure.loading:
                        state.alert = loadingAlert
                    default:
                        return .none
                    }
                    return .none
                }

            case .loadDrills:
                return .task {
                    await .persistenceClientDidLoad(
                        TaskResult { try await persistenceClient.loadDrills() }
                    )
                }

            case .setNavigationToStatistics(isActive: let isActive):
                if isActive == false {
                    state.statistics = nil
                }

                return .none
            }
        }
        .ifLet(\.session, action: /Action.session) {
            Session()
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
