//
//  DrillRunner.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Combine
import WatchKit
import WatchConnectivity

extension DrillRunner: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith: \(activationState.rawValue)")
        if let error = error { print(error) }
    }
}

final class DrillRunner: NSObject, ObservableObject {
    private let motion = MotionTracker()
    private let extendedRuntime = ExtendedRuntimeManager()

    private let session = WCSession.default

    private func sendContext() {
        print("Sending context!")

        let context = ResultContext(id: UUID(), potCount: potCount, missCount: missCount)
        guard let data = try? JSONEncoder().encode(context) else { return }

        session.sendMessageData(data) { reply in
            print("Reply data received!")
        } errorHandler: { error in
            print(error)
        }
    }

    @Published var isActive = false {
        didSet {
            // if not starting
            if oldValue != false {
                // if restart or stopping with more than 0 tries
                if isActive || potCount + missCount > 0 {
                    sendContext()
                }
            }

            if isActive {
                WKInterfaceDevice().play(.start)
                potCount = 0
                missCount = 0
                isPaused = false
            } else {
                WKInterfaceDevice().play(.stop)
                isPaused = true
            }
        }
    }

    @Published var isPaused = false {
        didSet {
            if isPaused {
                WKInterfaceDevice().play(.directionDown)
                motion.stop()
                extendedRuntime.stop()
            } else {
                WKInterfaceDevice().play(.directionUp)
                motion.start()
                extendedRuntime.start()
            }
        }
    }

    @Published var potCount = 0 {
        didSet {
            if isCompleted {
                WKInterfaceDevice().play(.success)
                isPaused = true
            } else {
                WKInterfaceDevice().play(.notification)
            }
        }
    }

    @Published var missCount = 0 {
        didSet {
            if isCompleted {
                WKInterfaceDevice().play(.success)
                isPaused = true
            } else {
                WKInterfaceDevice().play(.failure)
            }
        }
    }

    var remainingAttempts: Int {
        attempts - potCount - missCount
    }

    var isCompleted: Bool {
        remainingAttempts <= 0
    }

    private var attempts = 1

    func setAttempts(_ attempts: Int) {
        self.attempts = attempts
    }

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()

        session.delegate = self
        session.activate()

        motion.gesturePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                switch gesture {
                case .axisX:
                    self?.potCount += 1
                case .axisY:
                    self?.missCount += 1
                }
            }
            .store(in: &cancellables)
    }
}
