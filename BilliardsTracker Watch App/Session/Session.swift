//
//  Session.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-15.
//

import ComposableArchitecture
import Foundation
import WatchKit

struct Session: ReducerProtocol {
    enum Tab: Int {
        case control
        case progress
    }

    struct State: Equatable {
        let title: String
        let shotCount: Int

        var potCount = 0
        var missCount = 0
        var didPotLastShot: Bool?

        var isPaused = false

        @BindingState var currentTab: Session.Tab = .progress
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case pauseButtonDidTap
        case resumeButtonDidTap
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .pauseButtonDidTap:
                state.isPaused = true
                state.currentTab = .progress
                WKInterfaceDevice().play(.directionDown)
                return .none

            case .resumeButtonDidTap:
                state.isPaused = false
                state.currentTab = .progress
                WKInterfaceDevice().play(.directionUp)
                return .none

            }
        }
    }
}
