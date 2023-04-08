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

    func testChangingCurrentTab() async throws {
        await store.send(.didChangeCurrentTab(.tracked)) {
            $0.currentTab = .tracked
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

    func testNavigatingtoOnboardOnAppear() async throws {
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in false }
        store.dependencies.userDefaults.setHasOnboardBeenShown = { @Sendable _ in }

        await store.send(.onAppear) {
            $0.isNavigationToOnboardActive = true
        }
    }

    func testNavigationToSessionSetup() async throws {
        await store.send(.setNavigationToSessionSetup(isActive: true)) {
            $0.sessionSetup = SessionSetup.State(mode: .standalone)
            $0.isNavigationToSessionSetupActive = true
        }

        await store.send(.setNavigationToSessionSetup(isActive: false)) {
            $0.isNavigationToSessionSetupActive = false
        }

        await store.send(.didChangeCurrentTab(.tracked)) {
            $0.currentTab = .tracked
        }

        await store.send(.setNavigationToSessionSetup(isActive: true)) {
            $0.sessionSetup = SessionSetup.State(mode: .tracked)
            $0.isNavigationToSessionSetupActive = true
        }

        await store.send(.setNavigationToSessionSetup(isActive: false)) {
            $0.isNavigationToSessionSetupActive = false
        }
    }
}
