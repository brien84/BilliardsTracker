//
//  ConnectivityClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-03-07.
//

import ComposableArchitecture
import WatchConnectivity

struct ConnectivityClient {
    var receiveDrillContext: @Sendable  () async -> Void
    var sendResultContext: @Sendable (ResultContext) async -> Void
}

extension ConnectivityClient: DependencyKey {
    static var liveValue: Self {
        let connectivity = Connectivity()

        return Self(
            receiveDrillContext: {

            },
            sendResultContext: { context in

            }
        )
    }
}

extension DependencyValues {
    var connectivityClient: ConnectivityClient {
        get { self[ConnectivityClient.self] }
        set { self[ConnectivityClient.self] = newValue }
    }
}
