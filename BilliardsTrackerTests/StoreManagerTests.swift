//
//  StoreManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-07-05.
//

import Combine
import XCTest
@testable import BilliardsTracker

// swiftlint:disable force_try
final class StoreManagerTests: XCTestCase {
    var sut: StoreManager!
    var drillStore: DrillStore!
    var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        drillStore = try! DrillStore(inMemory: true, isPreview: true)
        sut = StoreManager(store: drillStore, userDefaults: userDefaults)
    }

    override func tearDownWithError() throws {
        drillStore = nil
        userDefaults = nil
        sut = nil
    }

    func testDrillsAreLoadedDuringInit() throws {
        XCTAssertGreaterThan(sut.drills.count, 0)
    }

    func testAddingDrill() throws {
        let currentDrillCount = sut.drills.count
        sut.addDrill(title: "", attempts: 10, isFailable: false)

        XCTAssertGreaterThan(sut.drills.count, currentDrillCount)
    }

    func testSavingErrorIsSet() throws {
        XCTAssertNil(sut.savingError)

        sut.addDrill(title: "", attempts: -1, isFailable: false)

        XCTAssertEqual(sut.savingError, .saving)
    }

    func testDeletingDrill() throws {
        let currentDrillCount = sut.drills.count
        sut.delete(drill: sut.drills.first!)

        XCTAssertLessThan(sut.drills.count, currentDrillCount)
    }

    func testSettingSortOptionSortsDrills() throws {
        let initialDrills = sut.drills

        XCTAssertEqual(initialDrills, sut.drills)

        let settings = SettingsManager(userDefaults: userDefaults)
        XCTAssertNotEqual(settings.sortOption, .dateCreated)
        settings.sortOption = .dateCreated

        XCTAssertNotEqual(initialDrills, sut.drills)
    }
}
