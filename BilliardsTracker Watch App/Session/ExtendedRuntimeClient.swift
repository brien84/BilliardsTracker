//
//  ExtendedRuntimeClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-15.
//

import ComposableArchitecture
import WatchKit

struct ExtendedRuntimeClient {
    var start: @Sendable () async -> Action?

    enum Action: Equatable {
        case didInvalidate(WKExtendedRuntimeSessionInvalidationReason)
        case willExpire
    }
}

extension ExtendedRuntimeClient: DependencyKey {
    static var liveValue: Self {
        let runtime = ExtendedRuntime()

        return Self(
            start: {
                await runtime.start().first(where: { _ in true })
            }
        )
    }
}

extension DependencyValues {
    var runtimeClient: ExtendedRuntimeClient {
        get { self[ExtendedRuntimeClient.self] }
        set { self[ExtendedRuntimeClient.self] = newValue }
    }
}

private actor ExtendedRuntime {
    private var session: WKExtendedRuntimeSession?

    func start() async -> AsyncStream<ExtendedRuntimeClient.Action> {
        AsyncStream<ExtendedRuntimeClient.Action> { continuation in
            session = WKExtendedRuntimeSession()

            let sessionDelegate = ExtendedRuntimeSessionDelegate(
                didInvalidate: { reason, _ in
                    continuation.yield(.didInvalidate(reason))
                    continuation.finish()
                },
                willExpire: {
                    continuation.yield(.willExpire)
                    continuation.finish()
                }
            )

            session?.delegate = sessionDelegate
            session?.start()

            continuation.onTermination = { @Sendable _ in
                Task {
                    _ = sessionDelegate
                    await self.session?.invalidate()
                }
            }
        }
    }
}

private class ExtendedRuntimeSessionDelegate: NSObject, WKExtendedRuntimeSessionDelegate {
    var didInvalidate: (WKExtendedRuntimeSessionInvalidationReason, Error?) -> Void
    var willExpire: () -> Void

    init(
        didInvalidate: @escaping (WKExtendedRuntimeSessionInvalidationReason, Error?) -> Void,
        willExpire: @escaping () -> Void
    ) {
        self.didInvalidate = didInvalidate
        self.willExpire = willExpire
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        print("extendedRuntimeSession didInvalidateWith: \(reason.description) \(error?.localizedDescription ?? "")")
        didInvalidate(reason, error)
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSessionDidStart")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        willExpire()
    }
}

private extension WKExtendedRuntimeSessionInvalidationReason {
    var description: String {
        switch self {
        case .none:
            return "The session ended normally."
        case .error:
            return "An error prevented the session from running:"
        case .expired:
            return "The session used all of its allocated time."
        case .resignedFrontmost:
            return "The app lost its frontmost status."
        case .sessionInProgress:
            return "This app already has a running session."
        case .suppressedBySystem:
            return "The system is in a state that doesn’t allow sessions of this type."
        default:
            return "Unknown."
        }
    }
}
