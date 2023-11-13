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
        var isNavigationToStandaloneSetupActive = false
        var isNavigationToTrackedActive = false
        var isNavigationToTrackedSetupActive = false

        var standalone = Session.State(
            title: "Standalone",
            shotCount: 9,
            isContinuous: true,
            isRestarting: false
        )
        var standaloneSetup = SessionSetup.State(mode: .standalone)
        var tracked = TrackedActivation.State()
        var trackedSetup = SessionSetup.State(mode: .tracked)
    }

    enum Action: Equatable {
        case onAppear

        case setNavigationToOnboard(isActive: Bool)
        case setNavigationToStandalone(isActive: Bool)
        case setNavigationToStandaloneSetup(isActive: Bool)
        case setNavigationToTracked(isActive: Bool)
        case setNavigationToTrackedSetup(isActive: Bool)

        case standalone(Session.Action)
        case standaloneSetup(SessionSetup.Action)
        case tracked(TrackedActivation.Action)
        case trackedSetup(SessionSetup.Action)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.standalone, action: /Action.standalone) {
            Session()
        }

        Scope(state: \.standaloneSetup, action: /Action.standaloneSetup) {
            SessionSetup()
        }

        Scope(state: \.tracked, action: /Action.tracked) {
            TrackedActivation()
        }

        Scope(state: \.trackedSetup, action: /Action.trackedSetup) {
            SessionSetup()
        }

        Reduce { state, action in
            switch action {

            case .onAppear:
                state.standaloneSetup.options = userDefaults.getOptionsFor(.standalone)
                state.trackedSetup.options = userDefaults.getOptionsFor(.tracked)
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
                state.standalone = Session.State(
                    title: "Standalone",
                    shotCount: state.standaloneSetup.shotCount,
                    isContinuous: state.standaloneSetup.isContinuous,
                    isRestarting: state.standaloneSetup.isRestarting
                )
                state.isNavigationToStandaloneActive = true
                return .none

            case .setNavigationToStandaloneSetup(let isActive):
                state.isNavigationToStandaloneSetupActive = isActive
                return .none

            case .setNavigationToTracked(isActive: let isActive):
                state.isNavigationToTrackedActive = isActive
                return .none

            case .setNavigationToTrackedSetup(let isActive):
                state.isNavigationToTrackedSetupActive = isActive
                return .none

            case .standalone(.stopButtonDidTap), .standalone(.result(.doneButtonDidTap)):
                state.isNavigationToStandaloneActive = false
                return .none

            case .standalone:
                return .none

            case .standaloneSetup:
                return .none

            case .tracked:
                return .none

            case .trackedSetup:
                return .none

            }
        }
    }
}
