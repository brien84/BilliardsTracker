//
//  Main.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-13.
//

import ComposableArchitecture
import Foundation

struct Main: ReducerProtocol {
    struct State: Equatable {
        let session = SessionManager()

        @BindingState var isNavigationToStandaloneActive = false
        @BindingState var isNavigationToTrackedActive = false
        @BindingState var isNavigationToOnboardActive = false

        init() {
            if !UserDefaults.standard.hasOnboardBeenShown {
                isNavigationToOnboardActive = true
                UserDefaults.standard.hasOnboardBeenShown = true
            }
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { _, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}

private extension UserDefaults {
    private static let hasOnboardBeenShownKey = "hasOnboardBeenShownKey"

    var hasOnboardBeenShown: Bool {
        get {
            bool(forKey: Self.hasOnboardBeenShownKey)
        }
        set {
            set(newValue, forKey: Self.hasOnboardBeenShownKey)
        }
    }
}
