//
//  LiveExtendedRuntimeClient.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-03-24.
//

import Dependencies
import WatchKit

extension ExtendedRuntimeClient: DependencyKey {
    static var liveValue: Self {
        let runtime = ExtendedRuntime()

        return Self(
            getExpirationStatus: {
                await runtime.isExpiring
            },
            start: {
                try? await Task.sleep(nanoseconds: 250_000_000)
                return await runtime.start()
            }
        )
    }
}

private actor ExtendedRuntime {
    private var delegate: ExtendedRuntimeSessionDelegate?
    private var session: WKExtendedRuntimeSession?

    /// `session` is considered expiring if it has less than 5 minutes of run time remaining.
    var isExpiring: Bool {
        guard let startDate = delegate?.startDate else { return false }
        return startDate.distance(to: .now) > 3300
    }

    func start() async -> WKExtendedRuntimeSessionInvalidationReason {
        await AsyncStream<WKExtendedRuntimeSessionInvalidationReason> { continuation in
            session = WKExtendedRuntimeSession()

            delegate = ExtendedRuntimeSessionDelegate(
                didInvalidate: { reason, _ in
                    continuation.yield(reason)
                    continuation.finish()
                }
            )

            session?.delegate = delegate
            session?.start()

            continuation.onTermination = { @Sendable _ in
                Task {
                    await self.session?.invalidate()
                }
            }
        }.first { _ in true } ?? .none
    }
}

private class ExtendedRuntimeSessionDelegate: NSObject, WKExtendedRuntimeSessionDelegate {
    var didInvalidate: (WKExtendedRuntimeSessionInvalidationReason, Error?) -> Void
    private(set) var startDate: Date?

    init(didInvalidate: @escaping (WKExtendedRuntimeSessionInvalidationReason, Error?) -> Void) {
        self.didInvalidate = didInvalidate
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
        startDate = .now
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {

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
