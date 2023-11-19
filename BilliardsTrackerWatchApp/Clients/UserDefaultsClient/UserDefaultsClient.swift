//
//  UserDefaultsClient.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import Dependencies
import Foundation

struct UserDefaultsClient {
    var getHasOnboardBeenShown: @Sendable () -> Bool
    var setHasOnboardBeenShown: @Sendable (Bool) async -> Void
    var getOptionsFor: @Sendable (Mode) -> SessionOptions
    var setOptionsFor: @Sendable (Mode, SessionOptions) -> Void
}

extension UserDefaultsClient: TestDependencyKey {
    static let testValue = Self(
        getHasOnboardBeenShown: {
            unimplemented("\(Self.self).hasOnboardBeenShown")
        },
        setHasOnboardBeenShown: { _ in
            unimplemented("\(Self.self).setHasOnboardBeenShown")
        },
        getOptionsFor: { _ in
            unimplemented("\(Self.self).getOptionsFor")
        },
        setOptionsFor: { _, _ in
            unimplemented("\(Self.self).setOptionsFor")
        }
    )

    static var previewValue: Self {
        inMemoryClient
    }

    static var inMemoryClient: Self {
        let name = "UserDefaultsClient.preview"
        let userDefaults = { UserDefaults(suiteName: name)! }
        userDefaults().removePersistentDomain(forName: name)

        return Self(
            getHasOnboardBeenShown: {
                userDefaults().bool(forKey: Self.hasOnboardBeenShownKey)
            },
            setHasOnboardBeenShown: { hasBeenShown in
                userDefaults().set(hasBeenShown, forKey: Self.hasOnboardBeenShownKey)
            },
            getOptionsFor: { mode in
                Self.getOptionsFor(mode, in: userDefaults())
            },
            setOptionsFor: { mode, options in
                Self.setOptionsFor(mode, options: options, in: userDefaults())
            }
        )
    }
}

extension DependencyValues {
    var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

extension UserDefaultsClient {
    static let hasOnboardBeenShownKey = "hasOnboardBeenShownKey"

    static func getOptionsKey(for mode: Mode) -> String {
        "optionsForMode\(mode)Key"
    }

    static func getOptionsFor(_ mode: Mode, in defaults: UserDefaults) -> SessionOptions {
        guard let data = defaults.data(forKey: getOptionsKey(for: mode)),
              let session = try? JSONDecoder().decode(SessionOptions.self, from: data)
        else { return SessionOptions() }
        return session
    }

    static func setOptionsFor(_ mode: Mode, options: SessionOptions, in defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(options) else { return }
        defaults.set(data, forKey: getOptionsKey(for: mode))
    }
}
