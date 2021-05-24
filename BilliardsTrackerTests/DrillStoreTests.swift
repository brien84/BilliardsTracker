//
//  DrillStoreTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-05-22.
//

import Combine
import XCTest
@testable import BilliardsTracker

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
            case .success():
                expectation.fulfill()
            case .failure(_):
                XCTFail()
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
            case .success():
                XCTFail()
            case .failure(_):
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
            case .success():
                expectation.fulfill()
            case .failure(_):
                XCTFail()
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
            case .success():
                XCTFail()
            case .failure(_):
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
            case .success():
                XCTFail()
            case .failure(_):
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)

        sut.addResult(from: ResultContext(potCount: 1, missCount: -1, date: Date()), to: drill)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(drill.results.count, initialCount)
    }
}
