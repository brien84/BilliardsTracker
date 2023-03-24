//
//  MotionClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-20.
//

import ComposableArchitecture
import CoreMotion

enum Gesture {
    case axisX
    case axisZ
}

struct MotionClient {
    var start: @Sendable () async -> AsyncThrowingStream<Gesture, Error>
}

extension MotionClient: DependencyKey {
    static let liveValue = Self(
        start: {
            AsyncThrowingStream { continuation in
                let manager = CMMotionManager()
                manager.deviceMotionUpdateInterval = 1/40
                let queue = OperationQueue()
                queue.name = "MotionClientQueue"
                queue.maxConcurrentOperationCount = 1

                var recognizer = GestureRecognizer(motions: [])
                let isLocked = LockIsolated(false)

                manager.startDeviceMotionUpdates(to: queue) { motion, error in
                    guard error == nil else {
                        continuation.finish(throwing: error)
                        return
                    }

                    guard !isLocked.value else { return }

                    recognizer = recognizer.addMotion(motion)

                    if let gesture = recognizer.recognizedGesture {
                        isLocked.setValue(true)
                        recognizer = GestureRecognizer(motions: [])
                        continuation.yield(gesture)

                        Task {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            isLocked.setValue(false)
                        }
                    }
                }

                continuation.onTermination = { @Sendable _ in
                    manager.stopDeviceMotionUpdates()
                }
            }
        }
    )

    static let testValue = Self(
        start: {
            unimplemented("\(Self.self).start")
        }
    )
}

extension DependencyValues {
    var motionClient: MotionClient {
        get { self[MotionClient.self] }
        set { self[MotionClient.self] = newValue }
    }
}

private struct GestureRecognizer {
    private var motions: [CMDeviceMotion]

    var recognizedGesture: Gesture? {
        if recognizeGesture(in: rotationsX) {
            return .axisX
        }

        if recognizeGesture(in: rotationsZ) {
            return .axisZ
        }

        return nil
    }

    private var rotationsX: [Double] {
        motions.compactMap { motion in
            let x = motion.rotationRate.x

            if x > 8 || x < -8 {
                return x
            }

            if x < 3, x > -3 {
                return 0
            }

            return nil
        }
    }

    private var rotationsZ: [Double] {
        motions.compactMap { motion in
            let z = motion.rotationRate.z

            if z > 3 || z < -3 {
                return z
            }

            if z < 2, z > -2 {
                return 0
            }

            return nil
        }
    }

    init(motions: [CMDeviceMotion]) {
        self.motions = motions

        while self.motions.count > 40 {
            if !self.motions.isEmpty {
                self.motions.removeLast()
            }
        }
    }

    func addMotion(_ motion: CMDeviceMotion?) -> GestureRecognizer {
        guard let motion = motion else { return self }

        var motions = motions
        motions.insert(motion, at: 0)
        return GestureRecognizer(motions: motions)
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
