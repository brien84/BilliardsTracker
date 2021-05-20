//
//  StatisticsManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-05-14.
//

import XCTest
@testable import BilliardsTracker

final class StatisticsManagerTests: XCTestCase {
    var sut: StatisticsManager!
    var store: DrillStore!

    override func setUpWithError() throws {
        store = DrillStore(inMemory: true)
    }

    override func tearDownWithError() throws {
        store = nil
        sut = nil
    }


}
