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

        var sortOrder: SortOrder {
            didSet {
                userDefaults.sortOrder = sortOrder
            }
        }

        init(userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
            self.sortOption = userDefaults.sortOption
            self.sortOrder = userDefaults.sortOrder
        }

        var sortDescriptor: SortDescriptor<Drill> {
            switch sortOption {
            case .dateCreated:
                return SortDescriptor(\.dateCreated, order: sortOrder)
            case .shotCount:
                return SortDescriptor(\.shotCount, order: sortOrder)
            case .title:
                return SortDescriptor(\.title, order: sortOrder)
            }
        }
    }

    enum Action: Equatable {
        case didSelectSortOption(SortOption)
        case didSelectSortOrder(SortOrder)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didSelectSortOption(let sortOption):
                state.sortOption = sortOption
                return .none

            case .didSelectSortOrder(let sortOrder):
                state.sortOrder = sortOrder
                return .none
            }
        }
    }
}

enum SortOption: Int, CaseIterable, Identifiable {
    var id: SortOption { self }

    case dateCreated
    case shotCount
    case title

    var imageName: String {
        switch self {
        case .dateCreated:
            return "calendar"
        case .shotCount:
            return "checklist"
        case .title:
            return "textformat"
        }
    }

    var title: String {
        switch self {
        case .dateCreated:
            return "Creation Date"
        case .shotCount:
            return "Shots"
        case .title:
            return "Title"
        }
    }
}

extension SortOrder: CaseIterable, Identifiable {
    public static var allCases: [SortOrder] {
        [.forward, .reverse]
    }

    public var id: SortOrder { self }

    func getTitle(for option: SortOption) -> String {
        switch self {
        case .forward:
            switch option {
            case .dateCreated:
                return "Oldest First"
            case .shotCount, .title:
                return "Ascending"
            }
        case .reverse:
            switch option {
            case .dateCreated:
                return "Newest First"
            case .shotCount, .title:
                return "Descending"
            }
        }
    }
}

private extension UserDefaults {
    private static let sortOptionKey = "sortOptionKey"
    private static let sortOrderKey = "sortOrderKey"

    var sortOption: SortOption {
        get {
            let rawValue = integer(forKey: Self.sortOptionKey)
            return SortOption(rawValue: rawValue) ?? .title
        }
        set {
            set(newValue.rawValue, forKey: Self.sortOptionKey)
        }
    }

    var sortOrder: SortOrder {
        get {
            let rawValue = bool(forKey: Self.sortOrderKey)
            return rawValue ? .forward : .reverse
        }
        set {
            set(newValue == .forward, forKey: Self.sortOptionKey)
        }
    }
}
