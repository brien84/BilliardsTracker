//
//  CreateDrill.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-23.
//

import ComposableArchitecture

struct CreateDrill: ReducerProtocol {
    struct State: Equatable {

    }

    enum Action: Equatable {
        case cancelButtonDidTap
        case saveButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {

            case .cancelButtonDidTap:
                return .none

            case .saveButtonDidTap:
                return .none
            }
        }
    }
}
