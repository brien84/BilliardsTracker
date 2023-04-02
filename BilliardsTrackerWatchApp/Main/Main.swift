//
//  Main.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-13.
//

import ComposableArchitecture
import Foundation

struct Main: ReducerProtocol {
    enum Tab: Int {
        case standalone
        case tracked
    }

    struct State: Equatable {
        var currentTab: Main.Tab = .standalone

        var standalone = Standalone.State()
        var tracked = Tracked.State()

        var isNavigationToStandaloneActive = false
        var isNavigationToTrackedActive = false
        var isNavigationToOnboardActive = false
    }

    enum Action: Equatable {
        case didChangeCurrentTab(Main.Tab)
        case onAppear

        case standalone(Standalone.Action)
        case tracked(Tracked.Action)

        case setNavigationToStandalone(isActive: Bool)
        case setNavigationToTracked(isActive: Bool)
        case setNavigationToOnboard(isActive: Bool)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.standalone, action: /Action.standalone) {
            Standalone()
        }

        Scope(state: \.tracked, action: /Action.tracked) {
            Tracked()
        }

        Reduce { state, action in
            switch action {

            case .didChangeCurrentTab(let tab):
                state.currentTab = tab
                return .none

            case .onAppear:
                guard !userDefaults.hasOnboardBeenShown() else { return .none }
                state.isNavigationToOnboardActive = true
                return .fireAndForget {
                    await userDefaults.setHasOnboardBeenShown(true)
                }

            case .standalone:
                return .none

            case .tracked:
                return .none

            case .setNavigationToStandalone(isActive: let isActive):
                state.isNavigationToStandaloneActive = isActive
                return .none

            case .setNavigationToTracked(isActive: let isActive):
                state.isNavigationToTrackedActive = isActive
                return .none

            case .setNavigationToOnboard(isActive: let isActive):
                state.isNavigationToOnboardActive = isActive
                return .none
            }
        }
    }
}
