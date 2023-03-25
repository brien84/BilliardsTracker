//
//  Tracked.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-19.
//

import ComposableArchitecture

struct Tracked: ReducerProtocol {
    struct State: Equatable {
        var session: Session.State?
    }

    enum Action: Equatable {
        case session(Session.Action)

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

            case .establishConnection:
                return .run { send in
                    for await drillContext in await connectivityClient.receiveDrillContext() {
                        await send(.connectivityClientDidReceiveDrillContext(drillContext))
                    }
                }
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
