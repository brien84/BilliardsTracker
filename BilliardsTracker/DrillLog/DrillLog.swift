//
//  DrillLog.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture

struct DrillLog: ReducerProtocol {
    struct State: Equatable {
        let drill: Drill
        let statistics: Statistics
        var alert: AlertState<Action>?

        @BindableState var isNavigationToFullHistoryActive = false

        init(drill: Drill) {
            self.drill = drill
            self.statistics = Statistics(drill: drill)
        }
    }

    enum Action: BindableAction, Equatable {
        case alertDidDismiss
        case binding(BindingAction<State>)
        case didDeleteDrill
        case didPressDeleteButton
        case didPressExitFullHistoryButton
        case didPressShowFullHistoryButton
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .alertDidDismiss:
                state.alert = nil
                return .none

            case .binding:
                return .none

            case .didDeleteDrill:
                return .none

            case .didPressDeleteButton:
                state.alert = deletionAlert
                return .none

            case .didPressExitFullHistoryButton:
                state.isNavigationToFullHistoryActive = false
                return .none

            case .didPressShowFullHistoryButton:
                state.isNavigationToFullHistoryActive = true
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
