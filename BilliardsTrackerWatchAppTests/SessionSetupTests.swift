//
//  SessionSetupTests.swift
//  BilliardsTrackerWatchAppTests
//
//  Created by Marius on 2023-04-03.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTrackerWatchApp

@MainActor
final class SessionSetupTests: XCTestCase {

    func testStoppingSessionByTappingSessionStopButton() async throws {
        let store = TestStore(
            initialState: SessionSetup.State(mode: .standalone, isNavigationToSessionActive: true),
            reducer: SessionSetup()
        )

        await store.send(.session(.stopButtonDidTap)) {
            $0.isNavigationToSessionActive = false
        }
    }

    func testStoppingSessionAfterGestureTrackingFailure() async throws {
        let store = TestStore(
            initialState: SessionSetup.State(mode: .standalone, isNavigationToSessionActive: true),
            reducer: SessionSetup()
        )

        await store.send(.session(.didDismissGestureTrackingError)) {
            $0.isNavigationToSessionActive = false
        }
    }

    func testStoppingSessionByTappingResultDoneButton() async throws {
        let result = Result.State(potCount: 6, missCount: 3)
        let session = Session.State(result: result, title: "", shotCount: 9, isContinuous: true)

        let store = TestStore(
            initialState: SessionSetup.State(
                mode: .standalone,
                isNavigationToSessionActive: true,
                session: session
            ),
            reducer: SessionSetup()
        )

        store.dependencies.connectivityClient.sendResultContext = { _ in return () }

        await store.send(.session(.result(.doneButtonDidTap))) {
            $0.isNavigationToSessionActive = false
            $0.session.result = nil
        }
    }

    func testChangingShotCount() async throws {
        let store = TestStore(
            initialState: SessionSetup.State(mode: .standalone),
            reducer: SessionSetup()
        )

        await store.send(.shotCountDidChange(69)) {
            $0.shotCount = 69
        }
    }

    func testNavigatingToStandaloneSession() async throws {
        let store = TestStore(
            initialState: SessionSetup.State(mode: .standalone, shotCount: 69),
            reducer: SessionSetup()
        )

        await store.send(.startStandaloneSession) {
            $0.isNavigationToSessionActive = true
            $0.session = Session.State(title: "Standalone", shotCount: 69, isContinuous: true)
        }
    }

    func testNavigatingToTrackedSession() async throws {
        let drillContext = DrillContext(isActive: true, isContinuous: true, shotCount: 9, title: "")

        let store = TestStore(
            initialState: SessionSetup.State(mode: .tracked),
            reducer: SessionSetup()
        )

        store.dependencies.connectivityClient.receiveDrillContext = {
            AsyncStream { continuation in
                continuation.yield(drillContext)
            }
        }

        await store.send(.establishConnection)

        await store.receive(.connectivityClientDidReceiveDrillContext(drillContext)) {
            $0.isNavigationToSessionActive = true
            $0.session = Session.State(
                title: drillContext.title,
                shotCount: drillContext.shotCount,
                isContinuous: drillContext.isContinuous
            )
        }

        let drillContext0 = DrillContext(isActive: false, isContinuous: true, shotCount: 9, title: "")

        store.dependencies.connectivityClient.receiveDrillContext = {
            AsyncStream { continuation in
                continuation.yield(drillContext0)
            }
        }

        await store.send(.establishConnection)

        await store.receive(.connectivityClientDidReceiveDrillContext(drillContext0)) {
            $0.isNavigationToSessionActive = false
        }

        await store.send(.endConnection)
    }

}
