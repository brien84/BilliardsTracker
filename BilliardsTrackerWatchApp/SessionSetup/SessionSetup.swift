//
//  SessionSetup.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import ComposableArchitecture

struct SessionSetup: ReducerProtocol {
    struct State: Equatable {
        let mode: Mode
        var shotCount = 9

        var isNavigationToSessionActive = false
        var session = Session.State(title: "Standalone", shotCount: 9, isContinuous: true)
    }

    enum Action: Equatable {
        case session(Session.Action)
        case shotCountDidChange(Int)
        case startStandaloneSession

        case establishConnection
        case endConnection
        case connectivityClientDidReceiveDrillContext(DrillContext)
    }

    @Dependency(\.connectivityClient) var connectivityClient

    private enum ConnectivityID { }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.session, action: /Action.session) {
            Session()
        }

        Reduce { state, action in
            switch action {

            case .session(.stopButtonDidTap):
                state.isNavigationToSessionActive = false
                return .none

            case .session(.result(.doneButtonDidTap)):
                state.isNavigationToSessionActive = false
                return .none

            case .session:
                return .none

            case .shotCountDidChange(let count):
                state.shotCount = count
                return .none

            case .startStandaloneSession:
                state.session = Session.State(
                    title: "Standalone",
                    shotCount: state.shotCount,
                    isContinuous: true
                )

                state.isNavigationToSessionActive = true
                return .none

            case .establishConnection:
                return .run { send in
                    for await drillContext in await connectivityClient.receiveDrillContext() {
                        await send(.connectivityClientDidReceiveDrillContext(drillContext))
                    }
                }
                .animation()
                .cancellable(id: ConnectivityID.self, cancelInFlight: true)

            case .endConnection:
                return .cancel(id: ConnectivityID.self)

            case .connectivityClientDidReceiveDrillContext(let context):
                if context.isActive {
                    state.session = Session.State(title: context.title, shotCount: context.shotCount, isContinuous: context.isContinuous)
                    state.isNavigationToSessionActive = true
                } else {
                    state.isNavigationToSessionActive = false
                }

                return .none
            }
        }
    }
}
