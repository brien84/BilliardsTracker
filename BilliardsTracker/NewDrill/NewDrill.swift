//
//  NewDrill.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-23.
//

import ComposableArchitecture

struct NewDrill: ReducerProtocol {
    struct State: Equatable {
        @BindingState var attempts = 9
        @BindingState var isFailable = false
        @BindingState var title = ""
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case cancelButtonDidTap
        case saveButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { _, action in
            switch action {

            case .binding:
                return .none

            case .cancelButtonDidTap:
                return .none

            case .saveButtonDidTap:
                return .none

            }
        }
    }
}
