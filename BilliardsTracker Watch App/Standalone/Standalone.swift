//
//  Standalone.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-14.
//

import ComposableArchitecture

struct Standalone: ReducerProtocol {
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
