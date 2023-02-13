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

enum SortOption: Int, CaseIterable, Identifiable {
    var id: SortOption { self }

    case attempts
    case dateCreated
    case title

    var descriptor: SortDescriptor<Drill> {
        switch self {
        case .attempts:
            return SortDescriptor(\Drill.attempts, order: .reverse)
        case .dateCreated:
            return SortDescriptor(\Drill.dateCreated, order: .reverse)
        case .title:
            return SortDescriptor(\Drill.title, order: .forward)
        }
    }

    var label: String {
        switch self {
        case .attempts:
            return "Attempts"
        case .dateCreated:
            return "Creation Date"
        case .title:
            return "Title"
        }
    }

    var imageName: String {
        switch self {
        case .attempts:
            return "repeat"
        case .dateCreated:
            return "calendar"
        case .title:
            return "textformat"
        }
    }
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
