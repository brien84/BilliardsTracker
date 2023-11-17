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
        getAppearance: {
            let rawValue = UserDefaults.standard.integer(forKey: Self.appearanceKey)
            return Appearance(rawValue: rawValue) ?? .system
        },
        setAppearance: { appearance in
            UserDefaults.standard.set(appearance.rawValue, forKey: Self.appearanceKey)
        },
        setAppVersion: {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            if let version, let build {
                UserDefaults.standard.set(version + " (\(build))", forKey: Self.versionKey)
            } else {
                UserDefaults.standard.set("1.0", forKey: Self.versionKey)
            }
        },
        getHasOnboardBeenShown: {
            if CommandLine.isUITesting { return false }
            return UserDefaults.standard.bool(forKey: Self.hasOnboardBeenShownKey)
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
