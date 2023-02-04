//
//  DrillItem.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-02-04.
//

import ComposableArchitecture

struct DrillItem: ReducerProtocol {
    struct State: Equatable {
        let drill: Drill
    }

    enum Action: Equatable {
        case didSelectDrill(Drill)
        case didTapStatisticsButton(Drill)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didSelectDrill:
                return .none
            case .didTapStatisticsButton:
                return .none
            }
        }
    }
}
