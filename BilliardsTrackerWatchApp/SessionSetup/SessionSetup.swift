//
//  SessionSetup.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-08.
//

import ComposableArchitecture

struct SessionOptions: Codable, Equatable {
    var shotCount: Int?

    init(shotCount: Int? = nil) {
        self.shotCount = shotCount
    }
}

struct SessionSetup: ReducerProtocol {
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
