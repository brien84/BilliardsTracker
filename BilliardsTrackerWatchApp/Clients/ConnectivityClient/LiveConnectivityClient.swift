//
//  LiveConnectivityClient.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-03-24.
//

import Dependencies
import WatchConnectivity

extension ConnectivityClient: DependencyKey {
    static var liveValue: Self {
        let connectivity = Connectivity()

        return Self(
            receiveDrillContext: {
                await connectivity.receiveDrillContext()
            },
            sendResultContext: { context in
                await connectivity.send(context: context)
            }
        )
    }
}

private actor Connectivity {
    private var delegate: SessionDelegate?
    private var session = WCSession.default

    func receiveDrillContext() async -> AsyncStream<DrillContext> {
        AsyncStream { continuation in
            self.delegate = SessionDelegate { context in
                continuation.yield(context)
            }

            session.delegate = delegate

            if session.activationState != .activated {
                session.activate()
            }

            continuation.onTermination = { @Sendable _ in
                Task {
                    await self.delegate?.isReadyForCommunication = false
                }
            }
        }
    }

    func send(context: ResultContext) async {
        guard session.activationState == .activated, session.isReachable else { return }
        guard let data = try? JSONEncoder().encode(context) else { return }
        session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
    }
}

private final class SessionDelegate: NSObject, WCSessionDelegate {
    var isReadyForCommunication = true

    let didReceiveDrillContext: @Sendable (DrillContext) -> Void

    init(didReceiveDrillContext: @escaping @Sendable (DrillContext) -> Void) {
        self.didReceiveDrillContext = didReceiveDrillContext
    }

    func session(
        _ session: WCSession,
        didReceiveMessageData messageData: Data,
        replyHandler: @escaping (Data) -> Void
    ) {
        guard let context = try? JSONDecoder().decode(DrillContext.self, from: messageData) else { return }

        if isReadyForCommunication {
            didReceiveDrillContext(context)

            if context.isActive {
                guard let data = try? JSONEncoder().encode(true) else { return }
                replyHandler(data)
            }
        } else {
            guard let data = try? JSONEncoder().encode(false) else { return }
            replyHandler(data)
        }
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
