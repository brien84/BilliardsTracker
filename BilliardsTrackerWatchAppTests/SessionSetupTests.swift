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

    func testNavigatingToContinuousToggle() async throws {
        await store.send(.setNavigationToContinuousToggle(isActive: true)) {
            $0.isNavigationToContinuousToggleActive = true
        }

        await store.send(.setNavigationToContinuousToggle(isActive: false)) {
            $0.isNavigationToContinuousToggleActive = false
        }
    }

    func testNavigatingToGesturesToggle() async throws {
        await store.send(.setNavigationToGesturesToggle(isActive: true)) {
            $0.isNavigationToGesturesToggleActive = true
        }

        await store.send(.setNavigationToGesturesToggle(isActive: false)) {
            $0.isNavigationToGesturesToggleActive = false
        }
    }

    func testNavigatingToRestartingToggle() async throws {
        await store.send(.setNavigationToRestartingToggle(isActive: true)) {
            $0.isNavigationToRestartingToggleActive = true
        }

        await store.send(.setNavigationToRestartingToggle(isActive: false)) {
            $0.isNavigationToRestartingToggleActive = false
        }
    }

    func testNavigatingToShotCountPicker() async throws {
        await store.send(.setNavigationToShotCountPicker(isActive: true)) {
            $0.isNavigationToShotCountPickerActive = true
        }

        await store.send(.setNavigationToShotCountPicker(isActive: false)) {
            $0.isNavigationToShotCountPickerActive = false
        }
    }

    func testTogglingIsContinuous() async throws {
        let isContinuous = store.state.options.isContinuous ?? true

        store.dependencies.userDefaults.setOptionsFor = { @Sendable _, options in
            XCTAssertEqual(options.isContinuous, !isContinuous)
        }

        await store.send(.isContinuousDidChange(!isContinuous)) {
            $0.options.isContinuous = !isContinuous
        }
    }

    func testTogglingGestures() async throws {
        let gesturesEnabled = store.state.options.gesturesEnabled ?? true

        store.dependencies.userDefaults.setOptionsFor = { @Sendable _, options in
            XCTAssertEqual(options.gesturesEnabled, !gesturesEnabled)
        }

        await store.send(.didToggleGestures(!gesturesEnabled)) {
            $0.options.gesturesEnabled = !gesturesEnabled
        }
    }

    func testTogglingIsRestarting() async throws {
        let isRestarting = store.state.options.isRestarting ?? true

        store.dependencies.userDefaults.setOptionsFor = { @Sendable _, options in
            XCTAssertEqual(options.isRestarting, !isRestarting)
        }

        await store.send(.isRestartingDidChange(!isRestarting)) {
            $0.options.isRestarting = !isRestarting
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
