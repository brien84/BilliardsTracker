//
//  SessionSetupTests.swift
//  BilliardsTrackerWatchAppTests
//
//  Created by Marius on 2023-11-09.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTrackerWatchApp

@MainActor
final class SessionSetupTests: XCTestCase {
    var store: TestStore<SessionSetup.State, SessionSetup.Action, SessionSetup.State, SessionSetup.Action, ()>!

    override func setUp() async throws {
        store = TestStore(
            initialState: SessionSetup.State(mode: .standalone),
            reducer: SessionSetup()
        )
    }

    override func tearDown() async throws {
        store = nil
    }

    func testNavigatingToShotCount() async throws {
        await store.send(.setNavigationToShotCount(isActive: true)) {
            $0.isNavigationToShotCountActive = true
        }

        await store.send(.setNavigationToShotCount(isActive: false)) {
            $0.isNavigationToShotCountActive = false
        }
    }

    func testChangingShotCount() async throws {
        let newShotCount = 78

        store.dependencies.userDefaults.setOptionsFor = { @Sendable _, options in
            XCTAssertEqual(options.shotCount, newShotCount)
        }

        await store.send(.shotCountDidChange(newShotCount)) {
            $0.options.shotCount = newShotCount
        }
    }
}
