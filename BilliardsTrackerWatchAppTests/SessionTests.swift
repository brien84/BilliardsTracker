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
    var session: Session.State!
    var store: TestStore<Session.State, Session.Action, Session.State, Session.Action, ()>!

    override func setUp() async throws {
        session = Session.State(title: "TEST", shotCount: 9, isContinuous: true, isRestarting: false)
        store = TestStore(initialState: session, reducer: Session())

        store.dependencies.motionClient.start = { @Sendable in
            AsyncThrowingStream { _ in }
        }

        store.dependencies.runtimeClient.getExpirationStatus = { @Sendable in
            false
        }

        store.dependencies.runtimeClient.start = { @Sendable in
            await AsyncStream { _ in }.first { _ in true } ?? .none
        }
    }

    override func tearDown() async throws {
        session = nil
        store = nil
    }

    func testTappingResultDoneButton() async throws {
        let result = Result.State(potCount: 5, missCount: 4)

        var localSession = session!
        localSession.result = result
        localSession.potCount = result.potCount
        localSession.missCount = result.missCount

        let localStore = TestStore(initialState: localSession, reducer: Session())

        localStore.dependencies.connectivityClient.sendResultContext = { context in
            XCTAssertEqual(context.potCount, result.potCount)
            XCTAssertEqual(context.missCount, result.missCount)
            return
        }

        await localStore.send(.result(.doneButtonDidTap)) {
            $0.result = nil
        }
    }

    func testTappingResultRestartButton() async throws {
        let result = Result.State(potCount: 5, missCount: 4)

        var localSession = session!
        localSession.result = result
        localSession.potCount = result.potCount
        localSession.missCount = result.missCount
        localSession.didPotLastShot = false

        let localStore = TestStore(initialState: localSession, reducer: Session())

        localStore.dependencies.connectivityClient.sendResultContext = { context in
            XCTAssertEqual(context.potCount, result.potCount)
            XCTAssertEqual(context.missCount, result.missCount)
            return
        }

        localStore.dependencies.motionClient = store.dependencies.motionClient
        localStore.dependencies.runtimeClient = store.dependencies.runtimeClient

        await localStore.send(.result(.restartButtonDidTap)) {
            $0.potCount = 0
            $0.missCount = 0
            $0.didPotLastShot = nil
            $0.result = nil
        }

        await localStore.skipInFlightEffects()
    }

    func testRegisteringShots() async throws {
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
        let localSession = Session.State(title: "TEST", shotCount: 2, isContinuous: true, isRestarting: false)
        let localStore = TestStore(initialState: localSession, reducer: Session() )

        localStore.dependencies.motionClient = store.dependencies.motionClient
        localStore.dependencies.runtimeClient = store.dependencies.runtimeClient

        await localStore.send(.onAppear)

        await localStore.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await localStore.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await localStore.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 2
            $0.result = Result.State(potCount: $0.potCount, missCount: $0.missCount)
        }
    }

    func testFailingNonContinuousDrill() async throws {
        let localSession = Session.State(title: "TEST", shotCount: 9, isContinuous: false, isRestarting: false)
        let localStore = TestStore(initialState: localSession, reducer: Session() )

        localStore.dependencies.motionClient = store.dependencies.motionClient
        localStore.dependencies.runtimeClient = store.dependencies.runtimeClient

        await localStore.send(.onAppear)

        await localStore.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = false
            $0.missCount = 1
            $0.result = Result.State(potCount: $0.potCount, missCount: $0.missCount)
        }
    }

    func testRestartingNonContinuousDrillOnMissedShot() async throws {
        let localSession = Session.State(title: "TEST", shotCount: 9, isContinuous: false, isRestarting: true)
        let localStore = TestStore(initialState: localSession, reducer: Session() )

        localStore.dependencies.motionClient = store.dependencies.motionClient
        localStore.dependencies.runtimeClient = store.dependencies.runtimeClient
        localStore.dependencies.connectivityClient.sendResultContext = { context in
            XCTAssertEqual(context.potCount, 1)
            XCTAssertEqual(context.missCount, 1)
            return
        }

        await localStore.send(.onAppear)

        await localStore.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await localStore.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await localStore.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = nil
            $0.potCount = 0
        }

        await localStore.skipInFlightEffects()
    }

    func testNonContinuousDrillDoesNotRestartWhenCompleted() async throws {
        let localSession = Session.State(title: "TEST", shotCount: 2, isContinuous: true, isRestarting: true)
        let localStore = TestStore(initialState: localSession, reducer: Session() )

        localStore.dependencies.motionClient = store.dependencies.motionClient
        localStore.dependencies.runtimeClient = store.dependencies.runtimeClient

        await localStore.send(.onAppear)

        await localStore.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 1
        }

        await localStore.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await localStore.send(.didRegisterShot(isSuccess: true)) {
            $0.didPotLastShot = true
            $0.potCount = 2
            $0.result = Result.State(potCount: $0.potCount, missCount: $0.missCount)
        }
    }

    func testFailingContinuousDrillDoesNotRestartSessionOnMissedShot() async throws {
        let localSession = Session.State(title: "TEST", shotCount: 9, isContinuous: true, isRestarting: true)
        let localStore = TestStore(initialState: localSession, reducer: Session() )

        localStore.dependencies.motionClient = store.dependencies.motionClient
        localStore.dependencies.runtimeClient = store.dependencies.runtimeClient

        await localStore.send(.onAppear)

        await localStore.send(.didRegisterShot(isSuccess: false)) {
            $0.didPotLastShot = false
            $0.missCount = 1
        }

        await localStore.receive(.didReceiveRuntimeClientExpirationStatus(false))

        await localStore.skipInFlightEffects()
    }

    func testResumingAndPausingSession() async throws {
        var localSession = session!
        localSession.isPaused = true

        let localStore = TestStore(initialState: localSession, reducer: Session())

        localStore.dependencies.motionClient = store.dependencies.motionClient
        localStore.dependencies.runtimeClient = store.dependencies.runtimeClient

        await localStore.send(.resumeButtonDidTap) {
            $0.isPaused = false
        }

        await localStore.send(.pauseButtonDidTap) {
            $0.isPaused = true
        }
    }

    func testUndoingShot() async throws {
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

    func testonDisappearStopsGestureTracking() async throws {
        await store.send(.onAppear)

        await store.send(.onDisappear)
    }

    func testTrackingGestures() async throws {
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
        enum TestError: Error {
            case error
        }

        store.dependencies.motionClient.start = { @Sendable in
            AsyncThrowingStream { throw TestError.error }
        }

        await store.send(.onAppear)

        await store.receive(.didEncounterGestureTrackingError) {
            $0.alert = AlertState {
                TextState("Attention!")
            } actions: {
                ButtonState(role: .cancel, action: .didDismissGestureTrackingError) {
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
        }
    }

    func testHandlingGestureTrackingErrorThrownByRuntimeClient() async throws {
        enum TestError: Error {
            case error
        }

        store.dependencies.runtimeClient.start = { @Sendable in
            WKExtendedRuntimeSessionInvalidationReason.error
        }

        await store.send(.onAppear)

        await store.receive(.didEncounterGestureTrackingError) {
            $0.alert = AlertState {
                TextState("Attention!")
            } actions: {
                ButtonState(role: .cancel, action: .didDismissGestureTrackingError) {
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
        }
    }

    func testExpiringRuntimeClientIsRestarted() async throws {
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
