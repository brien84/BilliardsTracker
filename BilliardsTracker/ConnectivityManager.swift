//
//  ConnectivityManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-13.
//

import Foundation
import WatchConnectivity

final class ConnectivityManager: NSObject {
    private let session = WCSession.default

    var isCounterpartReachable = false {
        didSet {
            print("isCounterpartReachable: \(isCounterpartReachable)")
        }
    }

    override init() {
        super.init()

        session.delegate = self
        session.activate()
    }
}

extension ConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated, session.isReachable {
            isCounterpartReachable = true
        } else {
            isCounterpartReachable = false
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.activationState == .activated, session.isReachable {
            isCounterpartReachable = true
        } else {
            isCounterpartReachable = false
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        isCounterpartReachable = false
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
