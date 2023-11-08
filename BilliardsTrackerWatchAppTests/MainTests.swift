//
//  MainTests.swift
//  BilliardsTrackerWatchAppTests
//
//  Created by Marius on 2023-03-24.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTrackerWatchApp

@MainActor
final class MainTests: XCTestCase {
    var store: TestStore<Main.State, Main.Action, Main.State, Main.Action, ()>!

    override func setUp() async throws {
        store = TestStore(initialState: Main.State(), reducer: Main())
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in true }
    }

    override func tearDown() async throws {
        store = nil
    }

    func testNavigatingToOnboard() async throws {
        await store.send(.setNavigationToOnboard(isActive: true)) {
            $0.isNavigationToOnboardActive = true
        }

        await store.send(.setNavigationToOnboard(isActive: false)) {
            $0.isNavigationToOnboardActive = false
        }
    }

    func testNavigatingtoOnboardOnAppear() async throws {
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in false }
        store.dependencies.userDefaults.setHasOnboardBeenShown = { @Sendable _ in }

        await store.send(.onAppear) {
            $0.isNavigationToOnboardActive = true
        }
    }

    func navigatingToStandaloneSession() async throws {
        await store.send(.setNavigationToStandalone(isActive: true)) {
            $0.standalone = Session.State(title: "Standalone", shotCount: 9, isContinuous: true)
            $0.isNavigationToStandaloneActive = true
        }
    }

    func testStoppingSessionByWithSessionStopButton() async throws {
        let store = TestStore(
            initialState: Main.State(isNavigationToStandaloneActive: true),
            reducer: Main()
        )

        await store.send(.standalone(.stopButtonDidTap)) {
            $0.isNavigationToStandaloneActive = false
        }
    }

    func testStoppingStandaloneSessionWithResultDoneButton() async throws {
        let result = Result.State(potCount: 6, missCount: 3)
        let session = Session.State(result: result, title: "", shotCount: 9, isContinuous: true)

        let store = TestStore(
            initialState: Main.State(
                isNavigationToStandaloneActive: true,
                standalone: session
            ),
            reducer: Main()
        )

        store.dependencies.connectivityClient.sendResultContext = { _ in return () }

        await store.send(.standalone(.result(.doneButtonDidTap))) {
            $0.isNavigationToStandaloneActive = false
            $0.standalone.result = nil
        }
    }

    func testNavigationToTracked() async throws {
        await store.send(.setNavigationToTracked(isActive: true)) {
            $0.tracked = TrackedActivation.State()
            $0.isNavigationToTrackedActive = true
        }

        await store.send(.setNavigationToTracked(isActive: false)) {
            $0.isNavigationToTrackedActive = false
        }
    }

}
