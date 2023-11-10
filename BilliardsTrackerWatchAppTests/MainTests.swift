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

    func testGettingStandaloneSetupOptionsOnAppear() async throws {
        let options = SessionOptions(shotCount: 15)
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in true }
        store.dependencies.userDefaults.getOptionsFor = { @Sendable _ in options }

        await store.send(.onAppear) {
            $0.standaloneSetup.options = options
        }
    }

    func testNavigatingtoOnboardOnAppear() async throws {
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in false }
        store.dependencies.userDefaults.setHasOnboardBeenShown = { @Sendable _ in }
        store.dependencies.userDefaults.getOptionsFor = { @Sendable _ in SessionOptions() }

        await store.send(.onAppear) {
            $0.isNavigationToOnboardActive = true
        }
    }

    func testNavigatingToOnboard() async throws {
        await store.send(.setNavigationToOnboard(isActive: true)) {
            $0.isNavigationToOnboardActive = true
        }

        await store.send(.setNavigationToOnboard(isActive: false)) {
            $0.isNavigationToOnboardActive = false
        }
    }

    func testNavigatingToStandaloneSetup() async throws {
        await store.send(.setNavigationToStandaloneSetup(isActive: true)) {
            $0.isNavigationToStandaloneSetupActive = true
        }

        await store.send(.setNavigationToStandaloneSetup(isActive: false)) {
            $0.isNavigationToStandaloneSetupActive = false
        }
    }

    func testNavigatingToStandaloneSession() async throws {
        let options = SessionOptions(shotCount: 64)

        let store = TestStore(
            initialState: Main.State(standaloneSetup: SessionSetup.State(mode: .standalone, options: options)),
            reducer: Main()
        )

        await store.send(.setNavigationToStandalone(isActive: true)) {
            $0.standalone = Session.State(title: "Standalone", shotCount: options.shotCount!, isContinuous: true)
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
