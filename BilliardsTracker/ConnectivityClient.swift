//
//  ConnectivityClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-29.
//

import ComposableArchitecture
import WatchConnectivity

struct ConnectivityClient {
    var begin: @Sendable () async -> Void
    var sendDrillContext: @Sendable (DrillContext) async -> Void
}

extension ConnectivityClient: DependencyKey {
    static var liveValue: Self {
        return Self(
            begin: {

            },
            sendDrillContext: { context in

            }
        )
    }

    static let testValue = Self(
        begin: {
            unimplemented("\(Self.self).begin")
        },
        sendDrillContext: { _ in
            unimplemented("\(Self.self).sendDrillContext")
        }
    )
}

extension DependencyValues {
    var connectivityClient: ConnectivityClient {
        get { self[ConnectivityClient.self] }
        set { self[ConnectivityClient.self] = newValue }
    }
}
