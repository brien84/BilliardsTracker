//
//  ConnectivityClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-29.
//

import Dependencies
import WatchConnectivity

enum ConnectivityResponse: Equatable {
    case success
    case failure(Failure)

    enum Failure: Error {
        case notReachable
        case notReady
    }
}

struct ConnectivityClient {
    var receiveResults: @Sendable () async -> AsyncStream<ResultContext>
    var sendDrillContext: @Sendable (DrillContext) async -> ConnectivityResponse
}

extension ConnectivityClient: TestDependencyKey {
    static let testValue = Self(
        receiveResults: {
            unimplemented("\(Self.self).receiveResults")
        },
        sendDrillContext: { _ in
            unimplemented("\(Self.self).sendDrillContext")
        }
    )

    static let previewValue = Self(
        receiveResults: {
            AsyncStream<ResultContext> {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                let randomInt = Int.random(in: 0...9)
                return ResultContext(
                    potCount: randomInt,
                    missCount: 9 - randomInt,
                    date: Date(timeIntervalSinceNow: 3600)
                )
            }
        },
        sendDrillContext: { _ in
            try? await Task.sleep(nanoseconds: 500_000_000)
            return ConnectivityResponse.success
        }
    )
}

extension DependencyValues {
    var connectivityClient: ConnectivityClient {
        get { self[ConnectivityClient.self] }
        set { self[ConnectivityClient.self] = newValue }
    }
}
