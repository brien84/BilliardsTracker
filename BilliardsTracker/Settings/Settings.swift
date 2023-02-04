//
//  Settings.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-02-04.
//

import ComposableArchitecture
import Foundation

struct Settings: ReducerProtocol {

    struct State: Equatable {
        var sortOption: SortOption
    }

    enum Action: Equatable {
        case didSelectSortOption(SortOption)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didSelectSortOption(let sortOption):
                state.sortOption = sortOption
                return .none
            }
        }
    }

}

enum SortOption: Int, CaseIterable, Identifiable {
    case attempts
    case dateCreated
    case title
}
