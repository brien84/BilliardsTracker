//
//  DrillRunner.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Combine
import Foundation

final class DrillRunner: ObservableObject {
    private let motion = MotionTracker()
    private let extendedRuntime = ExtendedRuntimeManager()

    @Published var isActive = false {
        didSet {
            if isActive {
                potCount = 0
                missCount = 0
                isPaused = false
            } else {
                isPaused = true
            }
        }
    }

    @Published var isPaused = false {
        didSet {
            if isPaused {
                motion.stop()
                extendedRuntime.stop()
            } else {
                motion.start()
                extendedRuntime.start()
            }
        }
    }

    @Published var potCount = 0
    @Published var missCount = 0

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
