//
//  Settings.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-02-04.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct Settings: ReducerProtocol {
    struct State: Equatable {
        var appearance = Appearance.system
        var sortOption = SortOption.title
        var sortOrder = SortOrder.forward

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
        case didSelectAppearance(Appearance)
        case didSelectSortOption(SortOption)
        case didSelectSortOrder(SortOrder)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didSelectAppearance(let appearance):
                state.appearance = appearance
                return .fireAndForget {
                    await userDefaults.setAppearance(appearance)
                }

            case .didSelectSortOption(let sortOption):
                state.sortOption = sortOption
                return .fireAndForget {
                    await userDefaults.setSortOption(sortOption)
                }

            case .didSelectSortOrder(let sortOrder):
                state.sortOrder = sortOrder
                return .fireAndForget {
                    await userDefaults.setSortOrder(sortOrder)
                }
            }
        }
    }
}

enum Appearance: Int, CaseIterable, Identifiable {
    var id: Appearance { self }

    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var imageName: String {
        switch self {
        case .system:
            return "gearshape"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
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
