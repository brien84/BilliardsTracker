//
//  ConnectivityClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-29.
//

import ComposableArchitecture
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
    var begin: @Sendable () async -> AsyncStream<ResultContext>
    var sendDrillContext: @Sendable (DrillContext) async -> Void
}

extension ConnectivityClient: DependencyKey {
    static var liveValue: Self {
        let connectivity = Connectivity()

        return Self(
            begin: {
                await connectivity.begin()
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

private actor Connectivity {
    var delegate: Delegate?
    var session: WCSession = WCSession.default

    func begin() async -> AsyncStream<ResultContext> {
        let stream = AsyncStream { continuation in
            self.delegate = Delegate { context in
                continuation.yield(context)
            }

            session.delegate = delegate
            session.activate()
        }

        return stream
    }
}

private final class Delegate: NSObject, WCSessionDelegate {

    let didReceiveResultContext: @Sendable (ResultContext) -> Void

    init(didReceiveResultContext: @escaping @Sendable (ResultContext) -> Void) {
        self.didReceiveResultContext = didReceiveResultContext
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let context = try? JSONDecoder().decode(ResultContext.self, from: messageData) else { return }

        didReceiveResultContext(context)
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {

    }

    func sessionReachabilityDidChange(_ session: WCSession) { }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
