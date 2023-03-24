//
//  Standalone.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-14.
//

import ComposableArchitecture

struct Standalone: ReducerProtocol {
    struct State: Equatable {
        var session: Session.State?
        var shotCount = 9
    }

    enum Action: Equatable {
        case session(Session.Action)
        case setNavigationToSession(isActive: Bool)
        case shotCountDidChange(Int)
    }

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

            case .setNavigationToSession(isActive: true):
                state.session = Session.State(title: "Standalone", shotCount: state.shotCount, isContinuous: true)
                return .none

            case .setNavigationToSession(isActive: false):
                state.session = nil
                return .none

            case .shotCountDidChange(let count):
                state.shotCount = count
                return .none
            }
        }
        .ifLet(\.session, action: /Action.session) {
            Session()
        }
    }
}
