//
//  SessionSetup.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import ComposableArchitecture

struct SessionSetup: ReducerProtocol {
    struct State: Equatable {
        var session: Session.State?
    }

    enum Action: Equatable {
        case session(Session.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .session:
                return .none
            }
        }
    }
}
