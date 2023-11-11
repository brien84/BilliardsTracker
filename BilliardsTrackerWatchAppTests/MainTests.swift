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
        let standaloneOptions = SessionOptions(isContinuous: Bool.random(), isRestarting: Bool.random(), shotCount: 15)
        let trackedOptions = SessionOptions(isRestarting: Bool.random())
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in true }
        store.dependencies.userDefaults.getOptionsFor = { @Sendable mode in
            switch mode {
            case .standalone:
                return standaloneOptions
            case .tracked:
                return trackedOptions
            }
        }

        await store.send(.onAppear) {
            $0.standaloneSetup.options = standaloneOptions
            $0.trackedSetup.options = trackedOptions
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

    func testNavigatingToStandaloneSession() async throws {
        let options = SessionOptions(isContinuous: Bool.random(), isRestarting: Bool.random(), shotCount: 64)

        let store = TestStore(
            initialState: Main.State(standaloneSetup: SessionSetup.State(mode: .standalone, options: options)),
            reducer: Main()
        )

        await store.send(.setNavigationToStandalone(isActive: true)) {
            $0.standalone = Session.State(
                title: "Standalone",
                shotCount: options.shotCount!,
                isContinuous: options.isContinuous!,
                isRestarting: options.isRestarting!
            )
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
        let session = Session.State(
            result: result,
            title: "",
            shotCount: 9,
            isContinuous: true,
            isRestarting: false
        )

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

    func testNavigatingToStandaloneSetup() async throws {
        await store.send(.setNavigationToStandaloneSetup(isActive: true)) {
            $0.isNavigationToStandaloneSetupActive = true
        }

        await store.send(.setNavigationToStandaloneSetup(isActive: false)) {
            $0.isNavigationToStandaloneSetupActive = false
        }
    }

    func testNavigationToTracked() async throws {
        let isRestarting = true
        let trackedSetup = SessionSetup.State(mode: .tracked, options: SessionOptions(isRestarting: isRestarting))
        let store = TestStore(initialState: Main.State(trackedSetup: trackedSetup), reducer: Main())

        await store.send(.setNavigationToTracked(isActive: true)) {
            $0.tracked = TrackedActivation.State(isRestarting: isRestarting)
            $0.isNavigationToTrackedActive = true
        }

        await store.send(.setNavigationToTracked(isActive: false)) {
            $0.isNavigationToTrackedActive = false
        }
    }

    func testNavigatingToTrackedSetup() async throws {
        await store.send(.setNavigationToTrackedSetup(isActive: true)) {
            $0.isNavigationToTrackedSetupActive = true
        }

        await store.send(.setNavigationToTrackedSetup(isActive: false)) {
            $0.isNavigationToTrackedSetupActive = false
        }
    }

}
