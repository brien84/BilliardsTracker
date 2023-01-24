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
    }

    enum Action: Equatable {
        case none
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .none:
                return .none
            }
        }
    }
}
