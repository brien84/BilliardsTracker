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
                isCompleted = false
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

    @Published private(set) var isCompleted = false {
        didSet {
            if isCompleted {
                isPaused = true
            }
        }
    }

    @Published private(set) var potCount = 0
    @Published private(set) var missCount = 0

    var remainingAttempts: Int {
        let remainingAttempts = attempts - potCount - missCount

        if remainingAttempts <= 0 {
            isCompleted = true
        }

        return remainingAttempts
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
