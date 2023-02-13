//
//  Main.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-13.
//

import ComposableArchitecture

struct Main: ReducerProtocol {
    struct State: Equatable {
        let session = SessionManager()
    }

    enum Action: Equatable {
        case none
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .none:
                return .none
            }
        }
    }
}
