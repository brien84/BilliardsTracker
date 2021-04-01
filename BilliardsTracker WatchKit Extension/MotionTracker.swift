//
//  MotionTracker.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-01.
//

import Combine
import CoreMotion

enum Gesture {
    case axisX
    case axisY
}

final class MotionTracker {
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 1/40
        return manager
    }()

    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MotionManagerQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    func start() {
        guard !motionManager.isDeviceMotionActive else { return }

        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            if let error = error { print("CMMotionManager: \(error)") }
            guard let motion = motion else { return }

            self?.registerRotation(motion.rotationRate)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }

    let gesturePublisher = PassthroughSubject<Gesture, Never>()

    private var rotationsX = [Double](repeating: 0.0, count: 30)
    private var rotationsZ = [Double](repeating: 0.0, count: 40)

    private func registerRotation(_ rotation: CMRotationRate) {
        if rotation.x > 8 || rotation.x < -8 {
            addRotation(x: rotation.x)
        }

        if rotation.x < 3, rotation.x > -3 {
            addRotation(x: 0)
        }

        if rotation.z > 3 || rotation.z < -3 {
            addRotation(z: rotation.z)
        }

        if rotation.z < 2, rotation.z > -2 {
            addRotation(z: 0)
        }
    }

    private func addRotation(x: Double) {
        rotationsX.insert(x, at: 0)

        if rotationsX.count > 30 {
            rotationsX.removeLast()
        }

        if recognizeGesture(in: rotationsX) {
            gesturePublisher.send(.axisX)
            rotationsX = [Double](repeating: 0.0, count: 30)
        }
    }

    private func addRotation(z: Double) {
        rotationsZ.insert(z, at: 0)

        if rotationsZ.count > 40 {
            rotationsZ.removeLast()
        }

        if recognizeGesture(in: rotationsZ) {
            gesturePublisher.send(.axisY)
            rotationsZ = [Double](repeating: 0.0, count: 30)
        }
    }

    private func recognizeGesture(in rotations: [Double]) -> Bool {
        var isRotationPositive: Bool?

        let flags = rotations.compactMap { value -> Bool? in
            guard value != 0 else { return nil }

            if let isPositive = isRotationPositive {
                if (value > 0) != isPositive {
                    isRotationPositive = !isPositive
                    return isRotationPositive
                } else {
                    return nil
                }
            } else {
                if value > 0 {
                    isRotationPositive = true
                } else {
                    isRotationPositive = false
                }

                return isRotationPositive
            }
        }

        if flags.count == 4 {
            return true
        } else {
            return false
        }
    }
}
