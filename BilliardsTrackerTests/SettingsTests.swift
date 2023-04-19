//
//  SettingsTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2023-04-19.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTracker

@MainActor
final class SettingsTests: XCTestCase {
    func testSelectingAppearance() async throws {
        let testAppearance = Appearance.dark

        let store = TestStore(initialState: Settings.State(), reducer: Settings())
        store.dependencies.userDefaults.setAppearance = { appearance in
            XCTAssertEqual(appearance, testAppearance)
        }

        await store.send(.didSelectAppearance(testAppearance)) {
            $0.appearance = testAppearance
        }
    }

    func testSelectingSortOption() async throws {
        let testOption = SortOption.shotCount

        let store = TestStore(initialState: Settings.State(), reducer: Settings())
        store.dependencies.userDefaults.setSortOption = { option in
            XCTAssertEqual(option, testOption)
        }

        await store.send(.didSelectSortOption(testOption)) {
            $0.sortOption = testOption
        }
    }

    func testSelectingSortOrder() async throws {
        let testOrder = SortOrder.reverse

        let store = TestStore(initialState: Settings.State(), reducer: Settings())
        store.dependencies.userDefaults.setSortOrder = { order in
            XCTAssertEqual(order, testOrder)
        }

        await store.send(.didSelectSortOrder(testOrder)) {
            $0.sortOrder = testOrder
        }
    }
}
