//
//  SessionSetup.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-08.
//

import ComposableArchitecture

struct SessionOptions: Codable, Equatable {
    var shotCount: Int?
}

struct SessionSetup: ReducerProtocol {
    struct State: Equatable {
        var mode: Mode
        var options = SessionOptions()

        var isNavigationToShotCountPickerActive = false

        var shotCount: Int {
            options.shotCount ?? 9
        }
    }

    enum Action: Equatable {
        case setNavigationToShotCountPicker(isActive: Bool)

        case isContinuousDidChange(Bool)
        case shotCountDidChange(Int)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .setNavigationToShotCountPicker(isActive: let isActive):
                state.isNavigationToShotCountPickerActive = isActive
                return .none

            case .isContinuousDidChange(let isContinuous):
                state.options.isContinuous = isContinuous
                userDefaults.setOptionsFor(state.mode, state.options)
                return .none

            case .shotCountDidChange(let shotCount):
                state.options.shotCount = shotCount
                userDefaults.setOptionsFor(state.mode, state.options)
                return .none
            }
        }
    }
}
