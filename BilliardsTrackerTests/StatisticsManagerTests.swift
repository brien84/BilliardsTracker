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
        store = try! DrillStore(inMemory: true)
    }

    override func tearDownWithError() throws {
        store = nil
        sut = nil
    }

    func testAfterDateNilCountsAllResults() throws {
        let testDate = Date()

        let drill = createDrill(attempts: 1)
        store.addResult(from: createResultContext(date: Date(timeInterval: -3600, since: testDate)), to: drill)
        store.addResult(from: createResultContext(date: Date(timeInterval: 3600, since: testDate)), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.results.count, 2)
    }

    func testResultsAreCountedOnlyAfterDate() throws {
        let testDate = Date()

        let drill = createDrill(attempts: 1)
        store.addResult(from: createResultContext(date: Date(timeInterval: -3600, since: testDate)), to: drill)
        store.addResult(from: createResultContext(date: Date(timeInterval: 3600, since: testDate)), to: drill)

        sut = StatisticsManager(drill: drill, afterDate: testDate)

        XCTAssertEqual(sut.results.count, 1)
    }

    func testStatisticsCalculation() throws {
        let drill = createDrill(attempts: 10)
        store.addResult(from: createResultContext(potCount: 5, missCount: 5), to: drill)
        store.addResult(from: createResultContext(potCount: 5, missCount: 5), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.totalAttempts, 20)
        XCTAssertEqual(sut.totalPotCount, 10)
        XCTAssertEqual(sut.totalMissCount, 10)
        XCTAssertEqual(sut.totalPottingPercentage, 50)
    }

    func testChartDataPoints() throws {
        let drill = createDrill(attempts: 10)

        store.addResult(from: createResultContext(potCount: 8, missCount: 2), to: drill)
        store.addResult(from: createResultContext(potCount: 2, missCount: 8), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.chartDataPoints, [0.8, 0.2])
    }

    // MARK: - Helpers

    private func createDrill(attempts: Int) -> Drill {
        store.createDrill(title: "", attempts: attempts, isFailable: false)
        return store.loadDrills().first!
    }

    private func createResultContext(potCount: Int = 1, missCount: Int = 1, date: Date = Date()) -> ResultContext {
        ResultContext(potCount: potCount, missCount: missCount, date: date)
    }
}
