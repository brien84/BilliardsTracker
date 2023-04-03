//
//  MotionClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-20.
//

import Dependencies

enum Gesture {
    case axisX
    case axisZ
}

struct MotionClient {
    var start: @Sendable () async -> AsyncThrowingStream<Gesture, Error>
}

extension MotionClient: TestDependencyKey {
    static let testValue = Self(
        start: {
            unimplemented("\(Self.self).start")
        }
    )

    static let previewValue = Self(
        start: {
            AsyncThrowingStream { _ in }
        }
    )
}

extension DependencyValues {
    var motionClient: MotionClient {
        get { self[MotionClient.self] }
        set { self[MotionClient.self] = newValue }
    }
}
