//
//  ConnectivityClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-03-07.
//

import ComposableArchitecture
import WatchConnectivity

struct ConnectivityClient {
    var receiveDrillContext: @Sendable () async -> AsyncStream<DrillContext>
    var sendResultContext: @Sendable (ResultContext) async -> Void
}

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

    static let testValue = Self(
        receiveDrillContext: {
            unimplemented("\(Self.self).receiveDrillContext")
        },
        sendResultContext: { _ in
            unimplemented("\(Self.self).sendResultContext")
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

    }
}
