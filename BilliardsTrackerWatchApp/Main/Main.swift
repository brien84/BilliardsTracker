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
        var isNavigationToStandaloneActive = false
        var isNavigationToTrackedActive = false

        var standalone = Session.State(title: "Standalone", shotCount: 9, isContinuous: true)
        var tracked = TrackedActivation.State()
    }

    enum Action: Equatable {
        case onAppear

        case setNavigationToOnboard(isActive: Bool)
        case setNavigationToStandalone(isActive: Bool)
        case setNavigationToTracked(isActive: Bool)

        case standalone(Session.Action)
        case tracked(TrackedActivation.Action)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.standalone, action: /Action.standalone) {
            Session()
        }

        Scope(state: \.tracked, action: /Action.tracked) {
            TrackedActivation()
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

            case .setNavigationToStandalone(let isActive):
                guard isActive else { return .none }
                state.standalone = Session.State(title: "Standalone", shotCount: 9, isContinuous: true)
                state.isNavigationToStandaloneActive = true
                return .none

            case .setNavigationToTracked(isActive: let isActive):
                state.isNavigationToTrackedActive = isActive
                return .none

            case .standalone(.stopButtonDidTap), .standalone(.result(.doneButtonDidTap)):
                state.isNavigationToStandaloneActive = false
                return .none

            case .standalone:
                return .none

            case .tracked:
                return .none

            }
        }
    }
}
