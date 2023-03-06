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

        var remainingShots: Int {
            let shots = shotCount - potCount - missCount
            guard shots > 0 else { return 0 }
            return shots
        }

        var currentTab: Session.Tab = .progress

        var result: Result.State?
    }

    enum Action: Equatable {
        case didRegisterShot(isSuccess: Bool)

        case didChangeCurrentTab(Session.Tab)

        case pauseButtonDidTap
        case resumeButtonDidTap
        case stopButtonDidTap
        case undoButtonDidTap

        case result(Result.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .result(.doneButtonDidTap):
                state.result = nil
                return .none

            case .result(.restartButtonDidTap):
                state.potCount = 0
                state.missCount = 0
                state.didPotLastShot = nil
                state.result = nil
                return .none

            case .didChangeCurrentTab(let tab):
                state.currentTab = tab
                return .none

            case .didRegisterShot(let isSuccess):
                guard state.remainingShots > 0 else { return .none }

                if isSuccess {
                    state.potCount += 1
                    WKInterfaceDevice().play(.notification)
                } else {
                    state.missCount += 1
                    WKInterfaceDevice().play(.failure)
                }

                state.didPotLastShot = isSuccess

                if state.remainingShots == 0 {
                    state.result = Result.State(potCount: state.potCount, missCount: state.missCount)
                }

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

            case .stopButtonDidTap:
                return .none

            case .undoButtonDidTap:
                guard let didPotLastShot = state.didPotLastShot else { return .none }

                if didPotLastShot {
                    state.potCount -= 1
                } else {
                    state.missCount -= 1
                }

                state.didPotLastShot = nil
                state.currentTab = .progress
                WKInterfaceDevice().play(.directionDown)
                return .none
            }
        }
        .ifLet(\.result, action: /Action.result) {
            Result()
        }
    }
}
