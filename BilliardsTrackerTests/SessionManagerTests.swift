//
//  SessionManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-07-05.
//

import Combine
import XCTest
@testable import BilliardsTracker

final class SessionManagerTests: XCTestCase {
    var sut: SessionManager!
    var drillStore: DrillStore!

    override func setUpWithError() throws {
        drillStore = try! DrillStore(inMemory: true, isPreview: true)
        sut = SessionManager(store: drillStore)
    }

    override func tearDownWithError() throws {
        drillStore = nil
        sut = nil
    }

    func testStartingNewSessionSetsRunStateToLoading() throws {
        let drill = drillStore.loadDrills().first!

        sut.start(drill: drill)

        XCTAssertEqual(sut.runState, .loading)
    }

    func testStartingNewSessionUpdatesStartDate() throws {
        let drill = drillStore.loadDrills().first!
        let initialStartDate = sut.startDate

        sut.start(drill: drill)

        XCTAssertNotEqual(sut.startDate, initialStartDate)
    }

    func testStartingNewSessionUpdatesSelectedDrill() throws {
        let drill = drillStore.loadDrills().first!

        sut.start(drill: drill)

        XCTAssertEqual(sut.selectedDrill, drill)
    }

}
