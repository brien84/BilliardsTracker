//
//  ConnectivityManager.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-12.
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
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.activationState == .activated, session.isReachable {
            isCounterpartReachable = true
        }
    }
}
