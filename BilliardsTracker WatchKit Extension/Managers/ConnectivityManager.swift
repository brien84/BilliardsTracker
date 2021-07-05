//
//  ConnectivityManager.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-12.
//

import Combine
import WatchConnectivity

final class ConnectivityManager: NSObject {
    private let session = WCSession.default

    var isCounterpartReachable = false {
        didSet {
            print("isCounterpartReachable: \(isCounterpartReachable)")
        }
    }

    var isReadyForCommunication = false {
        didSet {
            print("isReadyForCommunication: \(isReadyForCommunication)")
        }
    }

    let didReceiveDrillContext = PassthroughSubject<DrillContext, Never>()

    override init() {
        super.init()

        session.delegate = self
        session.activate()
    }

    func sendResultContext(_ context: ResultContext) {
        guard isCounterpartReachable, isReadyForCommunication else { return }
        guard let data = try? JSONEncoder().encode(context) else { return }

        session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
    }
}

extension ConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        guard let context = try? JSONDecoder().decode(DrillContext.self, from: messageData) else { return }

        if isReadyForCommunication {
            didReceiveDrillContext.send(context)

            if context.isActive {
                guard let data = try? JSONEncoder().encode(true) else { return }
                replyHandler(data)
            }
        } else {
            guard let data = try? JSONEncoder().encode(false) else { return }
            replyHandler(data)
        }
    }

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
}
