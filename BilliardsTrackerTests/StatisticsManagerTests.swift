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

    func testResultsAreCountedOnlyAfterDate() throws {
        let testDate = Date()

        let drill = createDrill(attempts: 1)
        store.addResult(from: createResultContext(date: Date(timeInterval: -3600, since: testDate)), to: drill)
        store.addResult(from: createResultContext(date: Date(timeInterval: 3600, since: testDate)), to: drill)

        sut = StatisticsManager(drill: drill, afterDate: testDate)

        XCTAssertEqual(sut.results.count, 1)
    }

    func testAllResultsAreCountedWhenAfterDateIsNil() throws {
        let testDate = Date()

        let drill = createDrill(attempts: 1)
        store.addResult(from: createResultContext(date: Date(timeInterval: -3600, since: testDate)), to: drill)
        store.addResult(from: createResultContext(date: Date(timeInterval: 3600, since: testDate)), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.results.count, 2)
    }

    func testStatisticsCalculation() throws {
        let drill = createDrill(attempts: 10)
        store.addResult(from: createResultContext(potCount: 5, missCount: 5), to: drill)
        store.addResult(from: createResultContext(potCount: 5, missCount: 5), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.attemptsCount, 20)
        XCTAssertEqual(sut.potCount, 10)
        XCTAssertEqual(sut.missCount, 10)
        XCTAssertEqual(sut.pottingPercentage, 50)
    }

    func testFailableStatisticsCalculation() throws {
        let drill = createDrill(attempts: 10, isFailable: true)
        store.addResult(from: createResultContext(potCount: 0, missCount: 1), to: drill)
        store.addResult(from: createResultContext(potCount: 4, missCount: 1), to: drill)
        store.addResult(from: createResultContext(potCount: 10, missCount: 0), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.failableCompletedCount, 1)
        XCTAssertEqual(sut.failableCompletionPercentage, 33)
        XCTAssertEqual(sut.averagePots, 4.6)
    }

    func testChartDataPointsCalculation() throws {
        let drill = createDrill(attempts: 10)
        store.addResult(from: createResultContext(potCount: 8, missCount: 2), to: drill)
        store.addResult(from: createResultContext(potCount: 2, missCount: 8), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.chartDataPoints, [0.8, 0.2])
    }

    func testOnlyFirst100DataPointsAreReturned() throws {
        let drill = createDrill(attempts: 10)

        for _ in 0..<150 {
            store.addResult(from: createResultContext(potCount: 5, missCount: 5), to: drill)
        }

        store.addResult(from: createResultContext(potCount: 10, missCount: 0), to: drill)

        sut = StatisticsManager(drill: drill)

        XCTAssertEqual(sut.chartDataPoints.count, 100)
        XCTAssertEqual(sut.chartDataPoints.last!, 1.0)
    }
    
    // MARK: - Helpers

    private func createDrill(attempts: Int, isFailable: Bool = false) -> Drill {
        store.createDrill(title: "", attempts: attempts, isFailable: isFailable)
        return store.loadDrills().first!
    }

    private func createResultContext(potCount: Int = 1, missCount: Int = 1, date: Date = Date()) -> ResultContext {
        ResultContext(potCount: potCount, missCount: missCount, date: date)
    }
}
