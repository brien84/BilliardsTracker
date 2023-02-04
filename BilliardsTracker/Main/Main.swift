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
        var createDrill: CreateDrill.State?
        var drillList = DrillList.State()
        var statistics: Statistics.State?
        var session: Session.State?

        var settings = Settings.State()

        var isNavigationToStatisticsActive: Bool {
            statistics != nil
        }

        var isNavigationToCreateDrillActive = false
        var isNavigationToSessionActive = false

        var selectedDrill: Drill?
        var startDate = Date()

        var isShowingLoadingIndicator = false

        var alert: AlertState<Action>?
    }

    enum Action: Equatable {
        case createDrill(CreateDrill.Action)
        case drillList(DrillList.Action)
        case statistics(Statistics.Action)
        case session(Session.Action)

        case settings(Settings.Action)

        case setNavigationToStatistics(isActive: Bool)
        case setNavigationToCreateDrill(isActive: Bool)
        case setNavigationToSession(isActive: Bool)

        case onAppear

        case connectivityClient(ResultContext)
        case connectivityClientReceived(ConnectivityResponse)

        case alertDismissed

        case loadDrills
        case persistenceClientDidLoad(TaskResult<[Drill]>)
        case persistenceClient(PersistenceResponse)
    }

    @Dependency(\.connectivityClient) var connectivityClient
    @Dependency(\.persistenceClient) var persistenceClient

    var body: some ReducerProtocol<State, Action> {

        Scope(state: \.settings, action: /Action.settings) {
            Settings()
        }

        Reduce { state, action in
            switch action {

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

            case .persistenceClient(let response):
                switch response {
                case .success:
                    return .task {
                        await .persistenceClientDidLoad(
                            TaskResult { try await persistenceClient.loadDrills() }
                        )
                    }.animation()

                case .failure(.saving):
                    state.alert = AlertState {
                        TextState("Something went wrong!")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("Latest changes will not be saved.")
                    }
                    return .none

                case .failure(.initialization):
                    state.alert = AlertState {
                        TextState("Something went terribly wrong!")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
                    }
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

                    if let drill = state.selectedDrill {
                        state.session = Session.State(drill: drill, startDate: state.startDate)
                    }

                    return .none

                case .failure(let error):
                    switch error {
                    case PersistenceResponse.Failure.initialization:
                        state.alert = AlertState {
                            TextState("Something went terribly wrong!")
                        } actions: {
                            ButtonState(role: .cancel) {
                                TextState("OK")
                            }
                        } message: {
                            TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
                        }
                    case PersistenceResponse.Failure.loading:
                        state.alert = AlertState {
                            TextState("Something went terribly wrong!")
                        } actions: {
                            ButtonState(role: .cancel) {
                                TextState("OK")
                            }
                        } message: {
                            TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
                        }
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

            case .alertDismissed:
                state.alert = nil
                return .none

            case .connectivityClient(let result):
                guard let drill = state.selectedDrill else { return .none }
                return .task {
                    .persistenceClient(await persistenceClient.insertResult(result, drill))
                }

            case .onAppear:
                return .run { send in
                    for await result in await connectivityClient.begin() {
                        await send(
                            .connectivityClient(result)
                        )
                    }
                }

            case .setNavigationToCreateDrill(isActive: let isActive):
                if isActive {
                    state.isNavigationToCreateDrillActive = true
                    state.createDrill = CreateDrill.State()
                } else {
                    state.isNavigationToCreateDrillActive = false
                }

                return .none

            case .createDrill(.cancelButtonDidTap):
                state.isNavigationToCreateDrillActive = false
                return .none

            case .createDrill(.saveButtonDidTap):
                state.isNavigationToCreateDrillActive = false
                let drill = Drill(entity: Drill.entity(), insertInto: nil)
                drill.title = state.createDrill?.title ?? "Drill Title"
                drill.title = drill.title.isEmpty ? "Drill Title" : drill.title
                drill.attempts = Int(state.createDrill?.attempts ?? 69)
                drill.isFailable = state.createDrill?.isFailable ?? false
                return .task {
                    .persistenceClient(await persistenceClient.createDrill(drill))
                }

            case .createDrill:
                return .none

            case .setNavigationToSession(isActive: let isActive):
                state.isNavigationToSessionActive = isActive
                return .none

            case .session(.didTapExitButton):
                state.isNavigationToSessionActive = false
                state.selectedDrill = nil
                return .fireAndForget {
                    let context = DrillContext(title: "", attempts: 0, isFailable: false, isActive: false)
                    _ = await connectivityClient.sendDrillContext(context)
                }

            case .session:
                return .none

            case .connectivityClientReceived(let response):
                state.isShowingLoadingIndicator = false

                if response == .success {
                    state.isNavigationToSessionActive = true
                }

                if response == .failure(.notReachable) {
                    state.selectedDrill = nil
                    state.alert = AlertState {
                        TextState("Watch app is not reachable!")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("Make sure BilliardsTracker Watch app is installed and running.")
                    }
                }

                if response == .failure(.notReady) {
                    state.selectedDrill = nil
                    state.alert = AlertState {
                        TextState("Watch app is not in Tracked mode!")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("Make sure Tracked mode is selected in Watch app.")
                    }
                }
                return .none

            case .drillList(.drillItem(id: let id, action: .didSelectDrill)):
                if let drill = state.drillList.drillItems[id: id]?.drill {
                    state.isShowingLoadingIndicator = true
                    state.startDate = Date()
                    state.selectedDrill = drill
                    state.session = Session.State(drill: drill, startDate: state.startDate)
                    let context = DrillContext(
                        title: drill.title,
                        attempts: drill.attempts,
                        isFailable: drill.isFailable,
                        isActive: true
                    )
                    return .task {
                        .connectivityClientReceived(await connectivityClient.sendDrillContext(context))
                    }
                } else {
                    return .none
                }

            case .drillList(.drillItem(id: let id, action: .didTapStatisticsButton)):
                if let drill = state.drillList.drillItems[id: id]?.drill {
                    state.statistics = Statistics.State(drill: drill)
                }

                return .none

            case .drillList:
                return .none

            case .setNavigationToStatistics(isActive: let isActive):
                if isActive == false {
                    state.statistics = nil
                }

                return .none

            case .statistics(.didTapDeleteButton):
                guard let drill = state.statistics?.drill else { return .none }
                return .task {
                    .persistenceClient(await persistenceClient.deleteDrill(drill))
                }

            case .statistics:
                return .none
            }
        }
        .ifLet(\.createDrill, action: /Action.createDrill) {
            CreateDrill()
        }
        .ifLet(\.session, action: /Action.session) {
            Session()
        }

    }
}
