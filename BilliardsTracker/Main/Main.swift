//
//  Main.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-23.
//

import ComposableArchitecture
import SwiftUI

struct Main: ReducerProtocol {
    struct State: Equatable {
        var createDrill: CreateDrill.State?
        var drillList = DrillList.State()

        var isNavigationToCreateDrillActive = false

        var needsToCreateDrill = false

    }

    enum Action: Equatable {
        case createDrill(CreateDrill.Action)
        case drillList(DrillList.Action)

        case setNavigationToCreateDrill(isActive: Bool)

        case updateDrillList([Drill])
    }

    var body: some ReducerProtocol<State, Action> {

        Reduce { state, action in
            switch action {

            case .setNavigationToCreateDrill(isActive: let isActive):
                if isActive {
                    state.needsToCreateDrill = false
                    state.isNavigationToCreateDrillActive = true
                    state.createDrill = CreateDrill.State()
                } else {
                    state.isNavigationToCreateDrillActive = false
                }

                return .none

            case .createDrill(.cancelButtonDidTap):
                state.isNavigationToCreateDrillActive = false
                return .none

            case .createDrill(.saveButtonDidTap):
                state.needsToCreateDrill = true
                state.isNavigationToCreateDrillActive = false
                return .none

            case .createDrill:
                return .none

            case .drillList:
                return .none

            case .updateDrillList(let drills):
                state.drillList = DrillList.State(drills: drills)
                return .none

            }
        }
        .ifLet(\.createDrill, action: /Action.createDrill) {
            CreateDrill()
        }

    }
}
