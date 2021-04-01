//
//  MotionTracker.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-01.
//

import CoreMotion

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

        motionManager.startDeviceMotionUpdates(to: queue) { motion, error in
            if let error = error { print("CMMotionManager: \(error)") }
            guard let motion = motion else { return }

            print(motion)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
