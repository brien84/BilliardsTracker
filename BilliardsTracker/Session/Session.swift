//
//  Session.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-21.
//

import ComposableArchitecture
import Foundation

struct Session: ReducerProtocol {
    struct State: Equatable {
        var alert: AlertState<Action>?
        let drill: Drill
        let startDate: Date
        let statistics: Statistics

        init(drill: Drill, startDate: Date) {
            self.drill = drill
            self.startDate = startDate
            self.statistics = Statistics(drill: drill, startDate: startDate)
        }
    }

    enum Action: Equatable {
        case alertDidDismiss
        case didTapExitButton
        case sessionDidExit
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .alertDidDismiss:
                state.alert = nil
                return .none

            case .didTapExitButton:
                state.alert = exitConfirmationAlert
                return .none

            case .sessionDidExit:
                return .none
            }
        }
    }

    var exitConfirmationAlert: AlertState<Session.Action> {
        AlertState {
            TextState("Confirmation")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
            ButtonState(role: .destructive, action: .sessionDidExit) {
                TextState("Yes")
            }
        } message: {
            TextState("Are you sure you want to quit session?")
        }
    }
}
