//
//  Session.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-21.
//

import ComposableArchitecture

struct Session: ReducerProtocol {
    struct State: Equatable {
        var statistics: StatisticsManager
    }

    enum Action: Equatable {
        case didTapExitButton
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didTapExitButton:
                return .none
            }
        }
    }
}
