//
//  LiveConnectivityClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-03-26.
//

import Dependencies
import WatchConnectivity

extension ConnectivityClient: DependencyKey {
    static var liveValue: Self {
        let connectivity = Connectivity()

        return Self(
            receiveResults: {
                await connectivity.receive()
            },
            sendDrillContext: { context in
                await connectivity.send(context: context)
            }
        )
    }
}

private actor Connectivity {
    private var delegate: Delegate?
    private var session: WCSession = WCSession.default

    func receive() async -> AsyncStream<ResultContext> {
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
        print("activationDidCompleteWith - \(session.debug)")
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("sessionReachabilityDidChange - \(session.debug)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive - \(session.debug)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate - \(session.debug)")
        session.activate()
    }
}

extension WCSession {
    var debug: String {
        "activationState: \(self.activationState), isReachable: \(self.isReachable)"
    }
}

extension WCSessionActivationState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .activated:
            return "activated"
        case .inactive:
            return "inactive"
        case .notActivated:
            return "notActivated"
        @unknown default:
            return "unknown"
        }
    }
}
