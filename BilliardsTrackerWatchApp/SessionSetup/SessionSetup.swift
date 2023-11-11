//
//  SessionSetup.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-08.
//

import ComposableArchitecture

struct SessionOptions: Codable, Equatable {
    var isContinuous: Bool?
    var isRestarting: Bool?
    var shotCount: Int?
}

struct SessionSetup: ReducerProtocol {
    struct State: Equatable {
        var mode: Mode
        var options = SessionOptions()

        var isNavigationToContinuousToggleActive = false
        var isNavigationToRestartingToggleActive = false
        var isNavigationToShotCountPickerActive = false

        var isContinuous: Bool {
            options.isContinuous ?? true
        }

        var isRestarting: Bool {
            options.isRestarting ?? false
        }

        var shotCount: Int {
            options.shotCount ?? 9
        }
    }

    enum Action: Equatable {
        case setNavigationToContinuousToggle(isActive: Bool)
        case setNavigationToRestartingToggle(isActive: Bool)
        case setNavigationToShotCountPicker(isActive: Bool)

        case isContinuousDidChange(Bool)
        case isRestartingDidChange(Bool)
        case shotCountDidChange(Int)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setNavigationToContinuousToggle(isActive: let isActive):
                state.isNavigationToContinuousToggleActive = isActive
                return .none

            case .setNavigationToRestartingToggle(isActive: let isActive):
                state.isNavigationToRestartingToggleActive = isActive
                return .none

            case .setNavigationToShotCountPicker(isActive: let isActive):
                state.isNavigationToShotCountPickerActive = isActive
                return .none

            case .isContinuousDidChange(let isContinuous):
                state.options.isContinuous = isContinuous
                userDefaults.setOptionsFor(state.mode, state.options)
                return .none

            case .isRestartingDidChange(let isRestarting):
                state.options.isRestarting = isRestarting
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
