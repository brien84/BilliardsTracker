//
//  ExtendedRuntimeClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-15.
//

import Dependencies
import WatchKit

struct ExtendedRuntimeClient {
    var getExpirationStatus: @Sendable () async -> Bool
    var start: @Sendable () async -> WKExtendedRuntimeSessionInvalidationReason
}

extension ExtendedRuntimeClient: TestDependencyKey {
    static let testValue = Self(
        getExpirationStatus: {
            unimplemented("\(Self.self).isExpiring")
        },
        start: {
            unimplemented("\(Self.self).start")
        }
    )

    static let previewValue = Self(
        getExpirationStatus: {
            false
        },
        start: {
            await AsyncStream { _ in }.first { _ in true } ?? .none
        }
    )
}

extension DependencyValues {
    var runtimeClient: ExtendedRuntimeClient {
        get { self[ExtendedRuntimeClient.self] }
        set { self[ExtendedRuntimeClient.self] = newValue }
    }
}
