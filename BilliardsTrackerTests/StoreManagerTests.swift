//
//  StoreManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-07-05.
//

import Combine
import XCTest
@testable import BilliardsTracker

final class StoreManagerTests: XCTestCase {
    var sut: StoreManager!
    var drillStore: DrillStore!

    override func setUpWithError() throws {
        drillStore = try! DrillStore(inMemory: true, isPreview: true)
        sut = StoreManager(store: drillStore)
    }

    override func tearDownWithError() throws {
        drillStore = nil
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
}
