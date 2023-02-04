//
//  DrillItem.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-02-04.
//

import ComposableArchitecture

struct DrillItem: ReducerProtocol {

    struct State: Equatable, Identifiable {
        let drill: Drill

        var id: ObjectIdentifier {
            drill.id
        }
    }

    enum Action: Equatable {
        case didSelectDrill
        case didTapStatisticsButton
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
