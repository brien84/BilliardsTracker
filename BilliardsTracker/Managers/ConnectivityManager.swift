//
//  ConnectivityManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-13.
//

import Combine
import WatchConnectivity

enum ConnectivityError: Error, Identifiable {
    var id: ConnectivityError { self }

    case notReachable
    case notReady
}

final class ConnectivityManager: NSObject {
    private let session = WCSession.default

    var isCounterpartReachable = false {
        didSet {
            print("isCounterpartReachable: \(isCounterpartReachable)")
        }
    }

    var didReceiveResultContext = PassthroughSubject<ResultContext, Never>()

    override init() {
        super.init()

        session.delegate = self
        session.activate()
    }

    func sendDrillContext(_ context: DrillContext) -> AnyPublisher<Void, ConnectivityError> {
        Future<Void, ConnectivityError> { [weak self] promise in
            guard let isCounterpartReachable = self?.isCounterpartReachable, isCounterpartReachable else {
                promise(.failure(.notReachable))
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                promise(.failure(.notReachable))
            }

            guard let data = try? JSONEncoder().encode(context) else { return }

            self?.session.sendMessageData(data) { replyData in
                guard let reply = try? JSONDecoder().decode(Bool.self, from: replyData) else { return }

                if reply {
                    promise(.success(()))
                } else {
                    promise(.failure(.notReady))
                }
            } errorHandler: { error in
                print("\(type(of: self)) \(#function): \(error.localizedDescription)")
                promise(.failure(.notReachable))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension ConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let context = try? JSONDecoder().decode(ResultContext.self, from: messageData) else { return }

        didReceiveResultContext.send(context)
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

    func sessionDidBecomeInactive(_ session: WCSession) {
        isCounterpartReachable = false
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
