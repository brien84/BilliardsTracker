//
//  UserDefaultsClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-01.
//

import Dependencies
import Foundation

struct UserDefaultsClient {
    var getAppearance: @Sendable () -> Appearance
    var setAppearance: @Sendable (Appearance) async -> Void
    var setAppVersion: @Sendable () async -> Void
    var getHasOnboardBeenShown: @Sendable () -> Bool
    var setHasOnboardBeenShown: @Sendable (Bool) async -> Void
    var getSortOption: @Sendable () -> SortOption
    var setSortOption: @Sendable (SortOption) async -> Void
    var getSortOrder: @Sendable () -> SortOrder
    var setSortOrder: @Sendable (SortOrder) async -> Void
}

extension UserDefaultsClient: TestDependencyKey {
    static let testValue = Self(
        getAppearance: {
            unimplemented("\(Self.self).getAppearance")
        },
        setAppearance: { _ in
            unimplemented("\(Self.self).setAppearance")
        },
        setAppVersion: {
            unimplemented("\(Self.self).setAppVersion")
        },
        getHasOnboardBeenShown: {
            unimplemented("\(Self.self).getHasOnboardBeenShown")
        },
        setHasOnboardBeenShown: { _ in
            unimplemented("\(Self.self).setHasOnboardBeenShown")
        },
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
            getAppearance: {
                let rawValue = userDefaults().integer(forKey: Self.appearanceKey)
                return Appearance(rawValue: rawValue) ?? .system
            },
            setAppearance: { appearance in
                userDefaults().set(appearance.rawValue, forKey: Self.appearanceKey)
            },
            setAppVersion: {
                userDefaults().set("1.0", forKey: Self.versionKey)
            },
            getHasOnboardBeenShown: {
                userDefaults().bool(forKey: Self.hasOnboardBeenShownKey)
            },
            setHasOnboardBeenShown: { hasBeenShown in
                userDefaults().set(hasBeenShown, forKey: Self.hasOnboardBeenShownKey)
            },
            getSortOption: {
                let rawValue = userDefaults().integer(forKey: Self.sortOptionKey)
                return SortOption(rawValue: rawValue) ?? .title
            },
            setSortOption: { option in
                userDefaults().set(option.rawValue, forKey: Self.sortOptionKey)
            },
            getSortOrder: {
                let rawValue = userDefaults().bool(forKey: Self.sortOrderKey)
                return rawValue ? .forward : .reverse
            },
            setSortOrder: { order in
                userDefaults().set(order == .forward, forKey: Self.sortOrderKey)
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

extension UserDefaultsClient {
    static let appearanceKey = "appearanceKey"
    static let hasOnboardBeenShownKey = "hasOnboardBeenShownKey"
    static let sortOptionKey = "sortOptionKey"
    static let sortOrderKey = "sortOrderKey"
    static let versionKey = "versionKey"
}
