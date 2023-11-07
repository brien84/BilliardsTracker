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
        var isNavigationToOnboardActive = false
        var isNavigationToSessionSetupActive = false
        var isNavigationToStandaloneActive = false

        var sessionSetup = SessionSetup.State(mode: .tracked)
        var standalone = Session.State(title: "Standalone", shotCount: 9, isContinuous: true)
    }

    enum Action: Equatable {
        case onAppear

        case setNavigationToOnboard(isActive: Bool)
        case setNavigationToSessionSetup(isActive: Bool)
        case setNavigationToStandalone(isActive: Bool)

        case sessionSetup(SessionSetup.Action)
        case standalone(Session.Action)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.sessionSetup, action: /Action.sessionSetup) {
            SessionSetup()
        }

        Scope(state: \.standalone, action: /Action.standalone) {
            Session()
        }

        Reduce { state, action in
            switch action {

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
                    state.sessionSetup = SessionSetup.State(mode: .tracked)
                }
                state.isNavigationToSessionSetupActive = isActive
                return .none

            case .setNavigationToStandalone(let isActive):
                guard isActive else { return .none }
                state.standalone = Session.State(title: "Standalone", shotCount: 9, isContinuous: true)
                state.isNavigationToStandaloneActive = true
                return .none

            case .sessionSetup:
                return .none

            case .standalone(.stopButtonDidTap), .standalone(.result(.doneButtonDidTap)):
                state.isNavigationToStandaloneActive = false
                return .none

            case .standalone:
                return .none

            }
        }
    }
}
