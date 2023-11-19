//
//  LiveUserDefaultsClient.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import Dependencies
import Foundation

extension UserDefaultsClient: DependencyKey {
    static let liveValue: Self = {
        if CommandLine.isUITesting {
            inMemoryClient
        } else {
            Self(
                getHasOnboardBeenShown: {
                    UserDefaults.standard.bool(forKey: Self.hasOnboardBeenShownKey)
                },
                setHasOnboardBeenShown: { hasBeenShown in
                    UserDefaults.standard.set(hasBeenShown, forKey: Self.hasOnboardBeenShownKey)
                },
                getOptionsFor: { mode in
                    Self.getOptionsFor(mode, in: UserDefaults.standard)
                },
                setOptionsFor: { mode, options in
                    Self.setOptionsFor(mode, options: options, in: UserDefaults.standard)
                }
            )
        }
    }()
}
