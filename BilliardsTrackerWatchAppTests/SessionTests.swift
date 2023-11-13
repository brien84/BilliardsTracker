//
//  SessionTests.swift
//  BilliardsTrackerWatchAppTests
//
//  Created by Marius on 2023-03-24.
//

import ComposableArchitecture
import XCTest
import WatchKit
@testable import BilliardsTrackerWatchApp

@MainActor
final class SessionTests: XCTestCase {
    typealias TestSessionStore = TestStore<Session.State, Session.Action, Session.State, Session.Action, ()>

    func makeTestStore(with session: Session.State) -> TestSessionStore {
        let store = TestStore(initialState: session, reducer: Session())

        store.dependencies.motionClient.start = { @Sendable in
            AsyncThrowingStream { _ in }
        }

        store.dependencies.runtimeClient.getExpirationStatus = { @Sendable in
            false
        }

        store.dependencies.runtimeClient.start = { @Sendable in
            await AsyncStream { _ in }.first { _ in true } ?? .none
        }

        return store
    }

    func makeTestStore(shotCount: Int, isContinuous: Bool, isRestarting: Bool) -> TestSessionStore {
        let session = Session.State(
            title: "Test Session",
            shotCount: shotCount,
            isContinuous: isContinuous,
            isRestarting: isRestarting
        )

        return makeTestStore(with: session)
    }

    func testFinishingCompletedSessionByTappingResultDoneButton() async throws {
        let result = Result.State(potCount: 5, missCount: 4)

        let session = Session.State(
            result: result,
            title: "Test Session",
            shotCount: result.potCount + result.missCount,
            isContinuous: true,
            isRestarting: false,
            potCount: result.potCount,
            missCount: result.missCount
        )

        let store = makeTestStore(with: session)

        store.dependencies.connectivityClient.sendResultContext = { context in
            XCTAssertEqual(context.potCount, result.potCount)
            XCTAssertEqual(context.missCount, result.missCount)
            return
        }

        await store.send(.result(.doneButtonDidTap)) {
            $0.result = nil
        }
    }

    func testRestartingCompletedSessionByTappingResultButton() async throws {
        let result = Result.State(potCount: 5, missCount: 4)

        let session = Session.State(
            result: result,
            title: "Test Session",
            shotCount: result.potCount + result.missCount,
            isContinuous: true,
            isRestarting: false,
            potCount: result.potCount,
            missCount: result.missCount,
            didPotLastShot: false
        )

        let store = makeTestStore(with: session)

        store.dependencies.connectivityClient.sendResultContext = { context in
            XCTAssertEqual(context.potCount, result.potCount)
            XCTAssertEqual(context.missCount, result.missCount)
            return
        }

        await store.send(.result(.restartButtonDidTap)) {
            $0.potCount = 0
            $0.missCount = 0
            $0.didPotLastShot = nil
            $0.result = nil
        }

        await store.skipInFlightEffects()
    }

    func testRegisteringShots() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)

        await store.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await store.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = false
            $0.missCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))
    }

    func testCompletingContinuousDrill() async throws {
        let store = makeTestStore(shotCount: 2, isContinuous: true, isRestarting: false)

        await store.send(.onAppear)

        await store.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = false
            $0.missCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await store.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = false
            $0.missCount = 2
            $0.result = Result.State(potCount: $0.potCount, missCount: $0.missCount)
        }
    }

    func testFailingNonContinuousDrill() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: false, isRestarting: false)

        await store.send(.onAppear)

        await store.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = false
            $0.missCount = 1
            $0.result = Result.State(potCount: $0.potCount, missCount: $0.missCount)
        }
    }

    func testRestartingNonContinuousDrillOnMissedShot() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: false, isRestarting: true)

        store.dependencies.connectivityClient.sendResultContext = { context in
            XCTAssertEqual(context.potCount, 1)
            XCTAssertEqual(context.missCount, 1)
            return
        }

        await store.send(.onAppear)

        await store.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await store.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = nil
            $0.potCount = 0
        }

        await store.skipInFlightEffects()
    }

    func testNonContinuousDrillDoesNotRestartWhenCompleted() async throws {
        let store = makeTestStore(shotCount: 2, isContinuous: true, isRestarting: true)

        await store.send(.onAppear)

        await store.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await store.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 2
            $0.result = Result.State(potCount: $0.potCount, missCount: $0.missCount)
        }
    }

    func testFailingContinuousDrillDoesNotRestartSessionOnMissedShot() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: true)

        await store.send(.onAppear)

        await store.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = false
            $0.missCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await store.skipInFlightEffects()
    }

    func testResumingAndPausingSession() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)

        await store.send(.pauseButtonDidTap) {
            $0.isPaused = true
        }

        await store.send(.resumeButtonDidTap) {
            $0.isPaused = false
        }

        await store.skipInFlightEffects()
    }

    func testUndoingShot() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)

        await store.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await store.send(.undoButtonDidTap) {
            $0.didPotLastShot = nil
            $0.potCount = 0
        }
    }

    func testNoEffectsAreRunningAfterOnDisappear() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)
        await store.send(.onAppear)
        await store.send(.onDisappear)
    }

    func testTrackingGestures() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)

        store.dependencies.motionClient.start = { @Sendable in
            AsyncThrowingStream { continuation in
                continuation.yield(.axisX)
            }
        }

        await store.send(.onAppear)

        await store.receive(.didRegisterShot(isSuccess: true)) {
            $0.potCount = 1
            $0.didPotLastShot = true
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await store.skipInFlightEffects()
    }

    func testHandlingGestureTrackingErrorThrownByMotionClient() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)

        store.dependencies.motionClient.start = { @Sendable in
            struct MotionError: Error { }
            return AsyncThrowingStream { throw MotionError() }
        }

        await store.send(.onAppear)

        await store.receive(.didEncounterGestureTrackingError) {
            $0.alert = gestureTrackingError
        }
    }

    func testHandlingGestureTrackingErrorThrownByRuntimeClient() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)

        store.dependencies.runtimeClient.start = { @Sendable in
            WKExtendedRuntimeSessionInvalidationReason.error
        }

        await store.send(.onAppear)

        await store.receive(.didEncounterGestureTrackingError) {
            $0.alert = gestureTrackingError
        }
    }

    func testExpiringRuntimeClientIsRestarted() async throws {
        let store = makeTestStore(shotCount: 9, isContinuous: true, isRestarting: false)

        store.dependencies.runtimeClient.getExpirationStatus = { @Sendable in
            true
        }

        await store.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await store.receive(.didReceiveRuntimeClientExpirationStatus(true))

        await store.skipInFlightEffects()
    }

}

private let gestureTrackingError: AlertState = {
    AlertState {
        TextState("Attention!")
    } actions: {
        ButtonState(role: .cancel, action: Session.Action.didDismissGestureTrackingError) {
            TextState("OK")
        }
    } message: {
        TextState(
            """
            BilliardsTracker could not initiate gesture tracking.
            Make sure no other workout apps are not actively running.
            If you encounter this error during the session,
            try pausing and then resuming the drill.
            """
        )
    }
}()
