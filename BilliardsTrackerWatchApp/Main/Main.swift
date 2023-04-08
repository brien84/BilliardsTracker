//
//  Main.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-13.
//

import ComposableArchitecture
import Foundation

enum Mode: Int {
    case standalone
    case tracked
}

struct Main: ReducerProtocol {
    struct State: Equatable {
        var currentTab = Mode.standalone

        var isNavigationToOnboardActive = false
        var isNavigationToSessionSetupActive = false

        var sessionSetup = SessionSetup.State(mode: .tracked)
    }

    enum Action: Equatable {
        case didChangeCurrentTab(Mode)
        case onAppear

        case setNavigationToOnboard(isActive: Bool)
        case setNavigationToSessionSetup(isActive: Bool)

        case sessionSetup(SessionSetup.Action)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.sessionSetup, action: /Action.sessionSetup) {
            SessionSetup()
        }

        Reduce { state, action in
            switch action {

            case .didChangeCurrentTab(let tab):
                state.currentTab = tab
                return .none

            case .onAppear:
                guard !userDefaults.getHasOnboardBeenShown() else { return .none }
                state.isNavigationToOnboardActive = true
                return .fireAndForget {
                    await userDefaults.setHasOnboardBeenShown(true)
                }

            case .setNavigationToOnboard(isActive: let isActive):
                state.isNavigationToOnboardActive = isActive
                return .none

            case .setNavigationToSessionSetup(isActive: let isActive):
                if isActive {
                    state.sessionSetup = SessionSetup.State(mode: state.currentTab)
                }
                state.isNavigationToSessionSetupActive = isActive
                return .none

            case .sessionSetup:
                return .none

            }
        }
    }
}
