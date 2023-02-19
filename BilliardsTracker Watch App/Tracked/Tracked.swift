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
        case setNavigationToSession(isActive: Bool)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .session(.stopButtonDidTap):
                state.session = nil
                return .none

            case .session:
                return .none

            case .setNavigationToSession(isActive: true):
                state.session = Session.State(title: "Standalone", shotCount: 9)
                return .none

            case .setNavigationToSession(isActive: false):
                state.session = nil
                return .none
            }
        }
        .ifLet(\.session, action: /Action.session) {
            Session()
        }
    }
}
