//
//  DrillRunner.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Combine
import WatchKit

final class DrillRunner: ObservableObject {
    private let motion = MotionTracker()
    private let extendedRuntime = ExtendedRuntimeManager()

    @Published var isActive = false {
        didSet {
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

    init() {
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
