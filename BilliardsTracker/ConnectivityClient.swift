//
//  ConnectivityClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-29.
//

import ComposableArchitecture
import WatchConnectivity

enum ConnectivityError: Error, Identifiable {
    var id: ConnectivityError { self }

    case notReachable
    case notReady
}

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
    var sendDrillContext: @Sendable (DrillContext) async -> ConnectivityResponse
}

extension ConnectivityClient: DependencyKey {
    static var liveValue: Self {
        let connectivity = Connectivity()

        return Self(
            begin: {
                await connectivity.begin()
            },
            sendDrillContext: { context in
                await connectivity.send(context: context)
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

    func send(context: DrillContext) async -> ConnectivityResponse {
        guard session.activationState == .activated, session.isReachable
        else { return ConnectivityResponse.failure(.notReachable) }

        guard let data = try? JSONEncoder().encode(context)
        else { return ConnectivityResponse.failure(.notReachable) }

        return await withCheckedContinuation { continuation in
            Task {
                var continuation: CheckedContinuation<ConnectivityResponse, Never>? = continuation

                session.sendMessageData(data) { replyData in
                    guard let reply = try? JSONDecoder().decode(Bool.self, from: replyData)
                    else {
                        continuation?.resume(returning: .failure(.notReady))
                        continuation = nil
                        return
                    }

                    if reply {
                        continuation?.resume(returning: .success)
                        continuation = nil
                    } else {
                        continuation?.resume(returning: .failure(.notReady))
                        continuation = nil
                    }
                } errorHandler: { error in
                    print("\(Self.self).sendDrillContext: \(error)")
                    continuation?.resume(returning: .failure(.notReachable))
                    continuation = nil
                }

                try await Task.sleep(nanoseconds: 5_000_000_000)
                continuation?.resume(returning: .failure(.notReachable))
                continuation = nil
            }
        }
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
