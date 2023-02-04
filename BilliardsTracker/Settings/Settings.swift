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
        private let userDefaults: UserDefaults

        var sortOption: SortOption {
            didSet {
                userDefaults.sortOption = sortOption
            }
        }

        init(userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
            self.sortOption = userDefaults.sortOption
        }
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

enum SortOption: Int {
    case attempts
    case dateCreated
    case title
}

private extension UserDefaults {
    private static let sortOptionKey = "sortOptionKey"

    var sortOption: SortOption {
        get {
            let rawValue = integer(forKey: Self.sortOptionKey)
            return SortOption(rawValue: rawValue) ?? .title
        }
        set {
            set(newValue.rawValue, forKey: Self.sortOptionKey)
        }
    }
}
