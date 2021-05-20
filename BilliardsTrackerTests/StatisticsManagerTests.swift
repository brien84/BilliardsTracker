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

    func testAfterDateNilCountsAllResults() throws {
        let testDate = Date()

        let drill = Drill(context: store.persistentContainer.viewContext)

        let result0 = DrillResult(context: store.persistentContainer.viewContext)
        result0.date = Date(timeInterval: -3600, since: testDate)
        result0.drill = drill

        let result1 = DrillResult(context: store.persistentContainer.viewContext)
        result1.date = Date(timeInterval: 3600, since: testDate)
        result1.drill = drill

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.results.count, 2)
    }

    func testResultsAreCountedOnlyAfterDate() throws {
        let testDate = Date()

        let drill = Drill(context: store.persistentContainer.viewContext)

        let result0 = DrillResult(context: store.persistentContainer.viewContext)
        result0.date = Date(timeInterval: -3600, since: testDate)
        result0.drill = drill

        let result1 = DrillResult(context: store.persistentContainer.viewContext)
        result1.date = Date(timeInterval: 3600, since: testDate)
        result1.drill = drill

        sut = StatisticsManager(drill: drill, afterDate: testDate)

        XCTAssertEqual(sut.results.count, 1)
    }

    func testStatisticsCalculation() throws {
        let drill = Drill(context: store.persistentContainer.viewContext)
        drill.attempts = 10

        let result0 = DrillResult(context: store.persistentContainer.viewContext)
        result0.potCount = 5
        result0.missCount = 5
        result0.drill = drill

        let result1 = DrillResult(context: store.persistentContainer.viewContext)
        result1.potCount = 5
        result1.missCount = 5
        result1.drill = drill

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.totalAttempts, 20)
        XCTAssertEqual(sut.totalPotCount, 10)
        XCTAssertEqual(sut.totalMissCount, 10)
        XCTAssertEqual(sut.totalPottingPercentage, 50)
    }

    func testChartDataPoints() throws {
        let drill = Drill(context: store.persistentContainer.viewContext)
        drill.attempts = 10

        let result0 = DrillResult(context: store.persistentContainer.viewContext)
        result0.date = Date(timeIntervalSinceReferenceDate: 1)
        result0.potCount = 8
        result0.missCount = 2
        result0.drill = drill

        let result1 = DrillResult(context: store.persistentContainer.viewContext)
        result1.date = Date(timeIntervalSinceReferenceDate: 50)
        result1.potCount = 2
        result1.missCount = 8
        result1.drill = drill

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.chartDataPoints, [0.8, 0.2])
    }
}
