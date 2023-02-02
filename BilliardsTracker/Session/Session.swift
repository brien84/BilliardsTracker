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
        var drill: Drill
        var results: [DrillResult]
        var statistics: StatisticsManager

        init(drill: Drill, startDate: Date) {
            self.drill = drill
            self.results = drill.results
            self.statistics = StatisticsManager(drill: drill, afterDate: startDate)
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
