//
//  UserDefaultsClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-01.
//

import Dependencies
import Foundation

struct UserDefaultsClient {
    var getSortOption: @Sendable () -> SortOption
    var setSortOption: @Sendable (SortOption) async -> Void
    var getSortOrder: @Sendable () -> SortOrder
    var setSortOrder: @Sendable (SortOrder) async -> Void
}

extension UserDefaultsClient: TestDependencyKey {
    static let testValue = Self(
        getSortOption: {
            unimplemented("\(Self.self).getSortOption")
        },
        setSortOption: { _ in
            unimplemented("\(Self.self).setSortOption")
        },
        getSortOrder: {
            unimplemented("\(Self.self).getSortOrder")
        },
        setSortOrder: { _ in
            unimplemented("\(Self.self).setSortOrder")
        }
    )

    static let previewValue: Self = {
        let userDefaults = { UserDefaults(suiteName: "UserDefaultsClient.preview")! }
        userDefaults().removePersistentDomain(forName: "UserDefaultsClient.preview")

        return Self(
            getSortOption: {
                let rawValue = userDefaults().integer(forKey: "sortOptionKey")
                return SortOption(rawValue: rawValue) ?? .title
            },
            setSortOption: { option in
                userDefaults().set(option.rawValue, forKey: "sortOptionKey")
            },
            getSortOrder: {
                let rawValue = userDefaults().bool(forKey: "sortOrderKey")
                return rawValue ? .forward : .reverse
            },
            setSortOrder: { order in
                userDefaults().set(order == .forward, forKey: "sortOrderKey")
            }
        )
    }()
}

extension DependencyValues {
    var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
