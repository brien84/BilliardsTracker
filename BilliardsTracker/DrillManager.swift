//
//  DrillManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-04.
//

import Foundation
import WatchConnectivity

final class DrillManager: NSObject, ObservableObject {
    private let session = WCSession.default

    override init() {
        super.init()

        session.delegate = self
        session.activate()
    }

}

extension DrillManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith: \(activationState.rawValue)")
        if let error = error { print(error) }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
}
