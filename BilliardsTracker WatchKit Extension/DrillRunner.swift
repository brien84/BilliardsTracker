//
//  DrillRunner.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Combine
import Foundation

enum HitType {
    case pot
    case miss
}

final class DrillRunner: ObservableObject {
    private let motion = MotionTracker()

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
            } else {
                motion.start()
            }
        }
    }

    @Published private(set) var potCount = 0
    @Published private(set) var missCount = 0

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
                    self?.add(.pot)
                case .axisY:
                    self?.add(.miss)
                }
            }
            .store(in: &cancellables)
    }

    func add(_ hit: HitType) {
        switch hit {
        case .pot:
            potCount += 1
        case .miss:
            missCount += 1
        }
    }
}
