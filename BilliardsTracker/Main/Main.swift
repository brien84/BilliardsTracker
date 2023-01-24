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
        var isNavigationToCreateDrillActive = false
    }

    enum Action: Equatable {
        case createDrill(CreateDrill.Action)
        case setNavigationToCreateDrill(isActive: Bool)
    }

    var body: some ReducerProtocol<State, Action> {

        Reduce { state, action in
            switch action {

            case .setNavigationToCreateDrill(isActive: let isActive):
                if isActive {
                    state.isNavigationToCreateDrillActive = true
                    state.createDrill = CreateDrill.State()
                } else {
                    state.isNavigationToCreateDrillActive = false
                }

                return .none

            case .createDrill(.cancelButtonDidTap), .createDrill(.saveButtonDidTap):
                state.isNavigationToCreateDrillActive = false
                return .none

            case .createDrill:
                return .none

            }
        }
        .ifLet(\.createDrill, action: /Action.createDrill) {
            CreateDrill()
        }

    }
}
