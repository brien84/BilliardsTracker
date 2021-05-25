//
//  SessionManager.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Combine
import WatchKit

enum Mode {
    case standalone
    case tracked
}

final class SessionManager: ObservableObject {
    private let connectivity = ConnectivityManager()
    private let extendedRuntime = ExtendedRuntimeManager()
    private let motion = MotionManager()

    @Published var mode: Mode? {
        didSet {
            if mode == .tracked {
                connectivity.isReadyForCommunication = true
            } else {
                connectivity.isReadyForCommunication = false
            }
        }
    }

    @Published var isActive = false {
        didSet {
            if isCompleted {
                let context = ResultContext(potCount: potCount, missCount: missCount, date: Date())
                connectivity.sendResultContext(context)
            }

            potCount = 0
            missCount = 0

            if isActive {
                WKInterfaceDevice().play(.start)
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

    var isCompleted: Bool {
        if isFailable {
            return missCount > 0 || remainingAttempts <= 0
        } else {
            return remainingAttempts <= 0
        }
    }

    private var isFailable = false

    private var attempts = 1
    private var didPotLastAttempt: Bool?
    @Published var potCount = 0
    @Published var missCount = 0

    var remainingAttempts: Int {
        attempts - potCount - missCount
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
                    self?.addAttempt(isSuccess: true)
                case .axisY:
                    self?.addAttempt(isSuccess: false)
                }
            }
            .store(in: &cancellables)
    }

    func setAttempts(_ attempts: Int) {
        self.attempts = attempts
    }

    func addAttempt(isSuccess: Bool) {
        if isSuccess {
            potCount += 1
        } else {
            missCount += 1
        }

        if isCompleted {
            WKInterfaceDevice().play(.success)
            isPaused = true
            didPotLastAttempt = nil
            return
        }

        WKInterfaceDevice().play(isSuccess ? .notification : .failure)
        didPotLastAttempt = isSuccess
    }

    func undo() {
        guard let didPotLastAttempt = didPotLastAttempt else { return }

        if didPotLastAttempt {
            potCount -= 1
        } else {
            missCount -= 1
        }

        self.didPotLastAttempt = nil
        WKInterfaceDevice().play(.directionDown)
    }
}
