//
//  StandaloneTests.swift
//  BilliardsTrackerWatchAppTests
//
//  Created by Marius on 2023-03-24.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTrackerWatchApp

@MainActor
final class StandaloneTests: XCTestCase {

    func testStoppingSessionByTappingSessionStopButton() async throws {
        let session = Session.State(title: "", shotCount: 9, isContinuous: true)

        let store = TestStore(
            initialState: Standalone.State(session: session),
            reducer: Standalone()
        )

        await store.send(.session(.stopButtonDidTap)) {
            $0.session = nil
        }
    }

    func testStoppingSessionAfterGestureTrackingFailure() async throws {
        let session = Session.State(title: "", shotCount: 9, isContinuous: true)

        let store = TestStore(
            initialState: Standalone.State(session: session),
            reducer: Standalone()
        )

        await store.send(.session(.didDismissGestureTrackingError)) {
            $0.session = nil
        }
    }

    func testStoppingSessionByTappingResultDoneButton() async throws {
        let result = Result.State(potCount: 6, missCount: 3)
        let session = Session.State(result: result, title: "", shotCount: 9, isContinuous: true)

        let store = TestStore(
            initialState: Standalone.State(session: session),
            reducer: Standalone()
        )

        store.dependencies.connectivityClient.sendResultContext = { _ in return () }

        await store.send(.session(.result(.doneButtonDidTap))) {
            $0.session = nil
        }
    }

    func testNavigatingToSession() async throws {
        let store = TestStore(initialState: Standalone.State(), reducer: Standalone())

        await store.send(.setNavigationToSession(isActive: true)) {
            $0.session = Session.State(title: "Standalone", shotCount: 9, isContinuous: true)
        }

        await store.send(.setNavigationToSession(isActive: false)) {
            $0.session = nil
        }
    }

    func testChangingShotCount() async throws {
        let store = TestStore(initialState: Standalone.State(), reducer: Standalone())

        await store.send(.shotCountDidChange(69)) {
            $0.shotCount = 69
        }
    }

}
