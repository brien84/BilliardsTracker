//
//  TrackedActivation.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import ComposableArchitecture

struct TrackedActivation: ReducerProtocol {
    struct State: Equatable {
        var isNavigationToSessionActive = false
        var session = Session.State(
            mode: .tracked,
            title: "",
            shotCount: 1,
            isContinuous: true,
            isRestarting: false,
            gesturesEnabled: true
        )
    }

    enum Action: Equatable {
        case setNavigationToSession(isActive: Bool)
        case session(Session.Action)

        case establishConnection
        case endConnection
        case connectivityClientDidReceiveDrillContext(DrillContext)
    }

    @Dependency(\.connectivityClient) var connectivityClient
    @Dependency(\.userDefaults) var userDefaults

    private enum ConnectivityID { }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.session, action: /Action.session) {
            Session()
        }

        Reduce { state, action in
            switch action {

            case .setNavigationToSession(isActive: let isActive):
                state.isNavigationToSessionActive = isActive
                return .none

            case .session(.stopButtonDidTap):
                state.isNavigationToSessionActive = false
                return .none

            case .session(.result(.doneButtonDidTap)):
                state.isNavigationToSessionActive = false
                return .none

            case .session:
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
                    let gesturesEnabled = userDefaults.getOptionsFor(.tracked).gesturesEnabled ?? true
                    state.session = Session.State(
                        mode: .tracked,
                        title: context.title,
                        shotCount: context.shotCount,
                        isContinuous: context.isContinuous,
                        isRestarting: false,
                        gesturesEnabled: gesturesEnabled
                    )
                    state.isNavigationToSessionActive = true
                } else {
                    state.isNavigationToSessionActive = false
                }

                return .none
            }
        }
    }
}
