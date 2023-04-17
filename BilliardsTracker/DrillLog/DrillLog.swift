//
//  DrillLog.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture

struct DrillLog: ReducerProtocol {
    struct State: Equatable {
        var alert: AlertState<Action>?
        let drill: Drill
        let statistics: Statistics

        init(drill: Drill) {
            self.drill = drill
            self.statistics = Statistics(drill: drill)
        }
    }

    enum Action: Equatable {
        case alertDidDismiss
        case didDeleteDrill
        case didPressDeleteButton
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .alertDidDismiss:
                state.alert = nil
                return .none

            case .didDeleteDrill:
                return .none

            case .didPressDeleteButton:
                state.alert = deletionAlert
                return .none
            }
        }
    }

    var deletionAlert: AlertState<DrillLog.Action> {
        AlertState {
            TextState("Confirmation")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
            ButtonState(role: .destructive, action: .didDeleteDrill) {
                TextState("Delete")
            }
        } message: {
            TextState("Are you sure you want to delete this drill?")
        }
    }
}
