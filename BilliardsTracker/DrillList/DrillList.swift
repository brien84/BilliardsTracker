//
//  DrillList.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture

struct DrillList: ReducerProtocol {
    struct State: Equatable {
        var drillItems: IdentifiedArrayOf<DrillItem.State>

        init(drills: [Drill] = []) {
            let drillItems = drills.map { DrillItem.State(drill: $0) }
            self.drillItems = IdentifiedArrayOf(uniqueElements: drillItems)
        }
    }

    enum Action: Equatable {
        case didTapNewDrillButton
        case drillItem(id: DrillItem.State.ID, action: DrillItem.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case.didTapNewDrillButton:
                return .none
            case .drillItem:
                return .none
            }
        }
        .forEach(\.drillItems, action: /Action.drillItem(id:action:)) {
            DrillItem()
        }
    }
}
