//
//  LiveUserDefaultsClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-01.
//

import Dependencies
import Foundation

extension UserDefaultsClient: DependencyKey {
    static let liveValue = Self(
        getHasOnboardBeenShown: {
            UserDefaults.standard.bool(forKey: Self.hasOnboardBeenShownKey)
        },
        setHasOnboardBeenShown: { hasBeenShown in
            UserDefaults.standard.set(hasBeenShown, forKey: Self.hasOnboardBeenShownKey)
        },
        getSortOption: {
            let rawValue = UserDefaults.standard.integer(forKey: Self.sortOptionKey)
            return SortOption(rawValue: rawValue) ?? .title
        },
        setSortOption: { option in
            UserDefaults.standard.set(option.rawValue, forKey: Self.sortOptionKey)
        },
        getSortOrder: {
            let rawValue = UserDefaults.standard.bool(forKey: Self.sortOrderKey)
            return rawValue ? .forward : .reverse
        },
        setSortOrder: { order in
            UserDefaults.standard.set(order == .forward, forKey: Self.sortOrderKey)
        }
    )
}

private extension UserDefaultsClient {
    static let hasOnboardBeenShownKey = "hasOnboardBeenShownKey"
    static let sortOptionKey = "sortOptionKey"
    static let sortOrderKey = "sortOrderKey"
}
