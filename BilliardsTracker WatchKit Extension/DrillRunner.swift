//
//  DrillRunner.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Combine
import WatchConnectivity
import WatchKit

enum Mode {
    case standalone
    case tracked
}

final class DrillRunner: ObservableObject {
    @Published var mode: Mode? {
        didSet {
            if mode == .tracked {
                connectivity.isReadyForCommunication = true
            } else {
                connectivity.isReadyForCommunication = false
            }
        }
    }

    private let motion = MotionTracker()
    private let extendedRuntime = ExtendedRuntimeManager()
    private let connectivity = ConnectivityManager()

    @Published var isActive = false {
        didSet {
            if isActive {
                WKInterfaceDevice().play(.start)
                missCount = 0
                potCount = 0
                isPaused = false
            } else {
                if oldValue != false {
                    WKInterfaceDevice().play(.stop)
                    isPaused = true
                }
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
            didPotLastAttempt = true

            if isCompleted {
                let context = ResultContext(potCount: potCount, missCount: missCount, date: Date())
                connectivity.sendResultContext(context)
                WKInterfaceDevice().play(.success)
                isPaused = true
            } else {
                WKInterfaceDevice().play(.notification)
            }
        }
    }

    @Published var missCount = 0 {
        didSet {
            didPotLastAttempt = false

            if isCompleted {
                let context = ResultContext(potCount: potCount, missCount: missCount, date: Date())
                connectivity.sendResultContext(context)
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

    private var isFailable = false

    var isCompleted: Bool {
        if isFailable {
            return missCount > 0 || remainingAttempts <= 0
        } else {
            return remainingAttempts <= 0
        }
    }

    private var attempts = 1

    func setAttempts(_ attempts: Int) {
        self.attempts = attempts
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        connectivity.didReceiveDrillContext
            .receive(on: RunLoop.main)
            .sink { [weak self] context in
                if context.isActive {
                    self?.attempts = context.attempts
                    self?.isFailable = context.isFailable
                    self?.isActive = true
                } else {
                    self?.isActive = false
                }
            }
            .store(in: &cancellables)

        motion.gesturePublisher
            .receive(on: RunLoop.main)
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

    private var didPotLastAttempt: Bool?

    func undo() {
        guard let didPotLastAttempt = didPotLastAttempt else { return }

        if didPotLastAttempt {
            potCount -= 1
        } else {
            missCount -= 1
        }

        self.didPotLastAttempt = nil
    }
}
