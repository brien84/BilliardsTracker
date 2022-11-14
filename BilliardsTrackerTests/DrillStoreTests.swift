//
//  DrillStoreTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-05-22.
//

import Combine
import XCTest
@testable import BilliardsTracker

// swiftlint:disable force_try
final class DrillStoreTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var sut: DrillStore!

    override func setUpWithError() throws {
        cancellables = []
        sut = try! DrillStore(inMemory: true, isPreview: true)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        sut = nil
    }

    func testLoadingDrills() throws {
        let drills = sut.loadDrills()

        XCTAssertGreaterThan(drills.count, 0)
    }

    func testCreatingDrill() throws {
        let initialCount = sut.loadDrills().count

        let expectation = self.expectation(description: "didSaveContext")

        sut.didSaveContext.sink { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("didSaveContext should succeed.")
            }
        }
        .store(in: &cancellables)

        sut.createDrill(title: "", attempts: 1, isFailable: true)

        waitForExpectations(timeout: 1)

        XCTAssertGreaterThan(sut.loadDrills().count, initialCount)
    }

    func testCreatingDrillValidation() throws {
        let initialCount = sut.loadDrills().count

        let expectation = self.expectation(description: "didSaveContext")

        sut.didSaveContext.sink { result in
            switch result {
            case .success:
                XCTFail("didSaveContext should fail.")
            case .failure:
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)

        sut.createDrill(title: "", attempts: -1, isFailable: true)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(sut.loadDrills().count, initialCount)
    }

    func testAddingDrillResult() throws {
        let drill = sut.loadDrills().first!
        let initialCount = drill.results.count

        let expectation = self.expectation(description: "didSaveContext")

        sut.didSaveContext.sink { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("didSaveContext should succeed.")
            }
        }
        .store(in: &cancellables)

        sut.addResult(from: ResultContext(potCount: 1, missCount: 1, date: Date()), to: drill)

        waitForExpectations(timeout: 1)

        XCTAssertGreaterThan(drill.results.count, initialCount)
    }

    func testAddingDrillResultPotCountValidation() throws {
        let drill = sut.loadDrills().first!
        let initialCount = drill.results.count

        let expectation = self.expectation(description: "didSaveContext")

        sut.didSaveContext.sink { result in
            switch result {
            case .success:
                XCTFail("didSaveContext should fail.")
            case .failure:
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)

        sut.addResult(from: ResultContext(potCount: -1, missCount: 1, date: Date()), to: drill)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(drill.results.count, initialCount)
    }

    func testAddingDrillResultMissCountValidation() throws {
        let drill = sut.loadDrills().first!
        let initialCount = drill.results.count

        let expectation = self.expectation(description: "didSaveContext")

        sut.didSaveContext.sink { result in
            switch result {
            case .success:
                XCTFail("didSaveContext should fail.")
            case .failure:
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)

        sut.addResult(from: ResultContext(potCount: 1, missCount: -1, date: Date()), to: drill)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(drill.results.count, initialCount)
    }

    func testDeletingDrill() throws {
        let initialCount = sut.loadDrills().count
        let drill = sut.loadDrills().first!

        let expectation = self.expectation(description: "didSaveContext")

        sut.didSaveContext.sink { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("didSaveContext should succeed.")
            }
        }
        .store(in: &cancellables)

        sut.delete(drill: drill)

        waitForExpectations(timeout: 1)

        XCTAssertLessThan(sut.loadDrills().count, initialCount)
    }

    func testSortingByAttempts() throws {
        sut = try! DrillStore(inMemory: true)

        let attempts = [14, 69, 1]

        attempts.forEach {
            sut.createDrill(title: "", attempts: $0, isFailable: false)
        }

        let drills = sut.loadDrills(sortedBy: .attempts)

        XCTAssertEqual(drills.count, 3)
        XCTAssertEqual([drills[0].attempts, drills[1].attempts, drills[2].attempts], [1, 14, 69])
    }

    func testSortingByDateCreated() throws {
        sut = try! DrillStore(inMemory: true)

        sut.createDrill(title: "T", attempts: 1, isFailable: false)
        sut.createDrill(title: "E", attempts: 1, isFailable: false)
        sut.createDrill(title: "A", attempts: 1, isFailable: false)

        let drills = sut.loadDrills(sortedBy: .dateCreated)

        XCTAssertEqual(drills.count, 3)
        XCTAssertEqual([drills[0].title, drills[1].title, drills[2].title], ["A", "E", "T"])
    }

    func testSortingByTitle() throws {
        sut = try! DrillStore(inMemory: true)

        let titles = ["B", "Z", "A"]

        titles.forEach {
            sut.createDrill(title: $0, attempts: 1, isFailable: false)
        }

        let drills = sut.loadDrills(sortedBy: .title)

        XCTAssertEqual(drills.count, 3)
        XCTAssertEqual([drills[0].title, drills[1].title, drills[2].title], ["A", "B", "Z"])
    }
}
