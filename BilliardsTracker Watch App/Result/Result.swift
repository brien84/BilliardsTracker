//
//  Result.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-20.
//

import ComposableArchitecture

struct Result: ReducerProtocol {
    struct State: Equatable {
        let potCount: Int
        let missCount: Int
    }

    enum Action: Equatable {
        case doneButtonDidTap
        case restartButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .doneButtonDidTap:
                return .none
            case .restartButtonDidTap:
                return .none
            }
        }
    }
}
