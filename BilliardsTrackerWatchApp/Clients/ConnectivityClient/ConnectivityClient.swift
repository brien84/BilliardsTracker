//
//  ConnectivityClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-03-07.
//

import Dependencies

struct ConnectivityClient {
    var receiveDrillContext: @Sendable () async -> AsyncStream<DrillContext>
    var sendResultContext: @Sendable (ResultContext) async -> Void
}

extension ConnectivityClient: TestDependencyKey {
    static let testValue = Self(
        receiveDrillContext: {
            unimplemented("\(Self.self).receiveDrillContext")
        },
        sendResultContext: { _ in
            unimplemented("\(Self.self).sendResultContext")
        }
    )

    static let previewValue = Self(
        receiveDrillContext: {
            AsyncStream { _ in }
        },
        sendResultContext: { _ in

        }
    )
}

extension DependencyValues {
    var connectivityClient: ConnectivityClient {
        get { self[ConnectivityClient.self] }
        set { self[ConnectivityClient.self] = newValue }
    }
}
