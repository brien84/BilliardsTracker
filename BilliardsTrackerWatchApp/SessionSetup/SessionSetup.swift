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
        var session: Session.State?
    }

    enum Action: Equatable {
        case session(Session.Action)
        case setNavigationToSession(isActive: Bool)
        case shotCountDidChange(Int)

        case establishConnection
        case endConnection
        case connectivityClientDidReceiveDrillContext(DrillContext)
    }

    @Dependency(\.connectivityClient) var connectivityClient

    private enum ConnectivityID { }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .session(.stopButtonDidTap), .session(.didDismissGestureTrackingError):
                state.session = nil
                return .none

            case .session(.result(.doneButtonDidTap)):
                state.session = nil
                return .none

            case .session:
                return .none

            case .setNavigationToSession(isActive: let isActive):
                guard isActive else { return .none }
                state.session = Session.State(
                    title: "Standalone",
                    shotCount: state.shotCount,
                    isContinuous: true
                )
                return .none

            case .shotCountDidChange(let count):
                state.shotCount = count
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
                } else {
                    state.session = nil
                }

                return .none
            }
        }
        .ifLet(\.session, action: /Action.session) {
            Session()
        }
    }
}
