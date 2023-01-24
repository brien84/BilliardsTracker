//
//  DrillList.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture

struct DrillList: ReducerProtocol {
    struct State: Equatable {
        let drills: IdentifiedArrayOf<Drill>

        init(drills: [Drill] = []) {
            self.drills = IdentifiedArrayOf(uniqueElements: drills)
        }
    }

    enum Action: Equatable {
        case didTapStatisticsButton(Drill)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didTapStatisticsButton:
                return .none
            }
        }
    }
}
