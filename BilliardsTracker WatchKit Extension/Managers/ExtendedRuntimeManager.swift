//
//  ExtendedRuntimeManager.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-03.
//

import WatchKit

final class ExtendedRuntimeManager: NSObject {
    private var session: WKExtendedRuntimeSession?

    private var startDate: Date?

    /// `session` is considered expiring if it has less than 5 minutes of run time remaining.
    var isExpiring: Bool {
        guard let startDate = startDate else { return false }
        return startDate.distance(to: Date()) > 3300
    }

    func start() {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }

    func stop() {
        if session?.state == .running {
            session?.invalidate()
        }
    }
}

extension ExtendedRuntimeManager: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        print("extendedRuntimeSession didInvalidateWith: \(reason.rawValue)")
        startDate = nil
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSessionDidStart")
        startDate = Date()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSessionWillExpire")
    }
}
