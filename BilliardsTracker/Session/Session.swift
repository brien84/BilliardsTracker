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
        let drill: Drill
        let startDate: Date
        let statistics: StatisticsClient

        init(drill: Drill, startDate: Date) {
            self.drill = drill
            self.startDate = startDate
            self.statistics = StatisticsClient(drill: drill, startDate: startDate)
        }
    }

    enum Action: Equatable {
        case didTapExitButton
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didTapExitButton:
                return .none
            }
        }
    }
}
