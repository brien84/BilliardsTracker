//
//  Statistics.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture

struct Statistics: ReducerProtocol {
    struct State: Equatable {
        let drill: Drill
        let statistics: StatisticsManager

        init(drill: Drill) {
            self.drill = drill
            self.statistics = StatisticsManager(drill: drill)
        }
    }

    enum Action: Equatable {
        case didTapDeleteButton
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didTapDeleteButton:
                return .none
            }
        }
    }
}
