//
//  UserDefaultsClient.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import Dependencies
import Foundation

struct UserDefaultsClient {

}

extension UserDefaultsClient: TestDependencyKey {
    static let previewValue: Self = {
        return Self(

        )
    }()

    static let testValue = Self(

    )
}

extension DependencyValues {
    var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
