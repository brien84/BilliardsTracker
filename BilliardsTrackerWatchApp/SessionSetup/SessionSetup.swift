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
        var mode: Mode
        var options = SessionOptions()

        var isNavigationToShotCountActive = false

        var shotCount: Int {
            options.shotCount ?? 9
        }
    }

    enum Action: Equatable {
        case setNavigationToShotCount(isActive: Bool)
        case shotCountDidChange(Int)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setNavigationToShotCount(isActive: let isActive):
                state.isNavigationToShotCountActive = isActive
                return .none

            case .shotCountDidChange(let shotCount):
                state.options.shotCount = shotCount
                userDefaults.setOptionsFor(state.mode, state.options)
                return .none
            }
        }
    }
}
