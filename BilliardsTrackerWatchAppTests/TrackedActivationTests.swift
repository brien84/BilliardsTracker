//
//  TrackedActivationTests.swift
//  BilliardsTrackerWatchAppTests
//
//  Created by Marius on 2023-04-03.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTrackerWatchApp

@MainActor
final class TrackedActivationTests: XCTestCase {

    func testNavigatingToSession() async throws {
        let startContext = DrillContext(isActive: true, isContinuous: true, shotCount: 9, title: "")

        let store = TestStore(
            initialState: TrackedActivation.State(),
            reducer: TrackedActivation()
        )

        store.dependencies.connectivityClient.receiveDrillContext = {
            AsyncStream { continuation in
                continuation.yield(startContext)
            }
        }

        let trackedOptions = SessionOptions(gesturesEnabled: Bool.random())
        store.dependencies.userDefaults.getOptionsFor = { @Sendable _ in
            return trackedOptions
        }

        await store.send(.establishConnection)

        await store.receive(.connectivityClientDidReceiveDrillContext(startContext)) {
            $0.isNavigationToSessionActive = true
            $0.session = Session.State(
                mode: .tracked,
                title: startContext.title,
                shotCount: startContext.shotCount,
                isContinuous: startContext.isContinuous,
                isRestarting: false,
                gesturesEnabled: trackedOptions.gesturesEnabled!
            )
        }

        let endContext = DrillContext(isActive: false, isContinuous: true, shotCount: 9, title: "")

        store.dependencies.connectivityClient.receiveDrillContext = {
            AsyncStream { continuation in
                continuation.yield(endContext)
            }
        }

        await store.send(.establishConnection)

        await store.receive(.connectivityClientDidReceiveDrillContext(endContext)) {
            $0.isNavigationToSessionActive = false
        }

        await store.send(.endConnection)
    }

    func testStoppingSessionByTappingSessionStopButton() async throws {
        let store = TestStore(
            initialState: TrackedActivation.State(isNavigationToSessionActive: true),
            reducer: TrackedActivation()
        )

        await store.send(.session(.stopButtonDidTap)) {
            $0.isNavigationToSessionActive = false
        }
    }

    func testStoppingSessionByTappingResultDoneButton() async throws {
        let result = Result.State(potCount: 6, missCount: 3)
        let session = Session.State(
            result: result,
            mode: .tracked,
            title: "",
            shotCount: 9,
            isContinuous: true,
            isRestarting: false,
            gesturesEnabled: true
        )

        let store = TestStore(
            initialState: TrackedActivation.State(
                isNavigationToSessionActive: true,
                session: session
            ),
            reducer: TrackedActivation()
        )

        store.dependencies.connectivityClient.sendResultContext = { _ in return () }

        await store.send(.session(.result(.doneButtonDidTap))) {
            $0.isNavigationToSessionActive = false
            $0.session.result = nil
        }
    }

}
