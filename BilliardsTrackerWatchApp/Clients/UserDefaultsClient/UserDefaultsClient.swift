//
//  UserDefaultsClient.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import Dependencies
import Foundation

struct UserDefaultsClient {
    var hasOnboardBeenShown: @Sendable () -> Bool
    var setHasOnboardBeenShown: @Sendable (Bool) async -> Void
}

extension UserDefaultsClient: TestDependencyKey {
    static let testValue = Self(
        hasOnboardBeenShown: {
            unimplemented("\(Self.self).hasOnboardBeenShown")
        },
        setHasOnboardBeenShown: { _ in
            unimplemented("\(Self.self).setHasOnboardBeenShown")
        }
    )

    static let previewValue: Self = {
        let userDefaults = { UserDefaults(suiteName: "UserDefaultsClient.preview")! }
        userDefaults().removePersistentDomain(forName: "UserDefaultsClient.preview")

        return Self(
            hasOnboardBeenShown: {
                userDefaults().bool(forKey: "hasOnboardBeenShownKey")
            },
            setHasOnboardBeenShown: { hasBeenShown in
                userDefaults().set(hasBeenShown, forKey: "hasOnboardBeenShownKey")
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
