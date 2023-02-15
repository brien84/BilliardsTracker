//
//  Session.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-15.
//

import ComposableArchitecture

struct Session: ReducerProtocol {
    struct State: Equatable {
        let title: String
        let shotCount: Int

        var potCount = 0
        var missCount = 0
        var didPotLastShot: Bool?
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
