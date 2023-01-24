//
//  Statistics.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture

struct Statistics: ReducerProtocol {
    struct State: Equatable {

    }

    enum Action: Equatable {
        case none
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .none:
                return .none
            }
        }
    }
}
