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

        var isNavigationToStatisticsActive: Bool {
            statistics != nil
        }

        var isNavigationToCreateDrillActive = false

        var isNavigationToSessionActive = false

        var needsToCreateDrill = false
        var needsToDeleteDrill = false

        var selectedDrill: Drill?
        var startDate = Date()

        var resultNeedsToBeCreated: ResultContext?

        var isShowingLoadingIndicator = false

        var alert: AlertState<Action>?
    }

    enum Action: Equatable {
        case createDrill(CreateDrill.Action)
        case drillList(DrillList.Action)
        case statistics(Statistics.Action)
        case session(Session.Action)

        case setNavigationToStatistics(isActive: Bool)
        case setNavigationToCreateDrill(isActive: Bool)
        case setNavigationToSession(isActive: Bool)

        case updateDrillList([Drill])

        case onAppear

        case connectivityClient(ResultContext)
        case connectivityClientReceived(ConnectivityResponse)

        case alertDismissed
    }

    @Dependency(\.connectivityClient) var connectivityClient

    var body: some ReducerProtocol<State, Action> {

        Reduce { state, action in
            switch action {

            case .alertDismissed:
                state.alert = nil
                return .none

            case .connectivityClient(let result):
                state.resultNeedsToBeCreated = result
                return .none

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
                    state.needsToCreateDrill = false
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
                state.needsToCreateDrill = true
                state.isNavigationToCreateDrillActive = false
                return .none

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

            case .drillList(.didTap(let drill)):
                state.isShowingLoadingIndicator = true

                state.startDate = Date()
                state.selectedDrill = drill
                state.session = Session.State(statistics:
                    StatisticsManager(drill: drill, afterDate: state.startDate)
                )
                let context = DrillContext(
                    title: drill.title,
                    attempts: drill.attempts,
                    isFailable: drill.isFailable,
                    isActive: true
                )
                return .task {
                    .connectivityClientReceived(await connectivityClient.sendDrillContext(context))
                }

            case .drillList(.didTapStatisticsButton(let drill)):
                state.needsToDeleteDrill = false
                state.statistics = Statistics.State(drill: drill)
                return .none

            case .drillList:
                return .none

            case .updateDrillList(let drills):
                state.drillList = DrillList.State(drills: drills)
                return .none

            case .setNavigationToStatistics(isActive: let isActive):
                if isActive == false {
                    state.statistics = nil
                }

                return .none

            case .statistics(.didTapDeleteButton):
                state.needsToDeleteDrill = true
                return .none

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
