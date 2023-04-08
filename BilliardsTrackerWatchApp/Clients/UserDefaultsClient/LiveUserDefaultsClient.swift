//
//  LiveUserDefaultsClient.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
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
        }
    )
}

private extension UserDefaultsClient {
    static let hasOnboardBeenShownKey = "hasOnboardBeenShownKey"
}
