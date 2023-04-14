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
        case didPressDrillLogButton
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didPressDrillLogButton:
                return .none
            case .didSelectDrill:
                return .none
            }
        }
    }
}
