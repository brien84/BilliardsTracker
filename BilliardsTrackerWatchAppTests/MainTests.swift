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
    }

    override func tearDown() async throws {
        store = nil
    }

    func testChangingCurrentTab() async throws {
        await store.send(.didChangeCurrentTab(.tracked)) {
            $0.currentTab = .tracked
        }
    }

    func testNavigatingToStandalone() async throws {
        await store.send(.setNavigationToStandalone(isActive: true)) {
            $0.isNavigationToStandaloneActive = true
        }

        await store.send(.setNavigationToStandalone(isActive: false)) {
            $0.isNavigationToStandaloneActive = false
        }
    }

    func testNavigatingToTracked() async throws {
        await store.send(.setNavigationToTracked(isActive: true)) {
            $0.isNavigationToTrackedActive = true
        }

        await store.send(.setNavigationToTracked(isActive: false)) {
            $0.isNavigationToTrackedActive = false
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

}
