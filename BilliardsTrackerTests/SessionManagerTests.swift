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
    var connectivity: MockConnectivityManager!
    var drillStore: DrillStore!

    override func setUpWithError() throws {
        connectivity = MockConnectivityManager()
        drillStore = try! DrillStore(inMemory: true, isPreview: true)
        sut = SessionManager(store: drillStore, connectivity: connectivity)
    }

    override func tearDownWithError() throws {
        connectivity = nil
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

    func testStartingSessionSendsDrillContextToConnectivityManager() throws {
        let drill = drillStore.loadDrills().first!
        connectivity.sentContextCallback = .success(())

        sut.start(drill: drill)

        XCTAssertEqual(connectivity.sentContext?.title, drill.title)
        XCTAssertEqual(connectivity.sentContext?.attempts, drill.attempts)
        XCTAssertEqual(connectivity.sentContext?.isFailable, drill.isFailable)
        XCTAssertEqual(connectivity.sentContext?.isActive, true)
    }

    func testSuccessfulConnectivityManagerCallbackSetsRunStateToRunning() throws {
        let drill = drillStore.loadDrills().first!
        connectivity.sentContextCallback = .success(())

        sut.start(drill: drill)
        waitForPublisher()

        XCTAssertEqual(sut.runState, .running)
        XCTAssertEqual(sut.connectivityError, nil)
    }

    func testFailedConnectivityManagerCallbackSetsConnectivityErrorNotReady() throws {
        let drill = drillStore.loadDrills().first!
        connectivity.sentContextCallback = .failure(.notReady)

        sut.start(drill: drill)
        waitForPublisher()

        XCTAssertEqual(sut.runState, .stopped)
        XCTAssertEqual(sut.connectivityError, .notReady)
    }

    func testFailedConnectivityManagerCallbackSetsConnectivityErrorNotReachable() throws {
        let drill = drillStore.loadDrills().first!
        connectivity.sentContextCallback = .failure(.notReachable)

        sut.start(drill: drill)
        waitForPublisher()

        XCTAssertEqual(sut.runState, .stopped)
        XCTAssertEqual(sut.connectivityError, .notReachable)
    }

    func testNewSessionCannotBeInitiatedIfRunStateIsRunning() throws {
        let drill = drillStore.loadDrills().first!
        connectivity.sentContextCallback = .success(())

        sut.start(drill: drill)
        waitForPublisher()

        XCTAssertEqual(sut.runState, .running)
        XCTAssertEqual(sut.connectivityError, nil)

        sut.start(drill: drill)
        XCTAssertEqual(sut.runState, .running)
    }

    func testReceivingAndSavingResultContext() throws {
        connectivity.sentContextCallback = .success(())
        let drill = drillStore.loadDrills().first!
        let initialResultsCount = drill.results.count

        let resultPotCount = 420
        let resultMissCount = 69
        let resultDate = Date()

        sut.start(drill: drill)
        waitForPublisher()

        connectivity.sendResultContext(ResultContext(potCount: resultPotCount, missCount: resultMissCount, date: resultDate))
        waitForPublisher()

        XCTAssertGreaterThan(drill.results.count, initialResultsCount)

        let testResult = drill.results.first { $0.date == resultDate }!
        XCTAssertEqual(testResult.potCount, resultPotCount)
        XCTAssertEqual(testResult.missCount, resultMissCount)
    }

    // MARK: - Helpers

    func waitForPublisher() {
        let exp = expectation(description: "Waiting for publisher")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    final class MockConnectivityManager: WatchCommunication {
        var sentContext: DrillContext?
        var sentContextCallback: Result<Void, ConnectivityError> = .success(())

        var didReceiveResultContext = PassthroughSubject<ResultContext, Never>()

        func sendDrillContext(_ context: DrillContext) -> AnyPublisher<Void, ConnectivityError> {
            sentContext = context

            return Future<Void, ConnectivityError> { [unowned self] promise in
                promise(sentContextCallback)
            }
            .eraseToAnyPublisher()
        }

        func sendResultContext(_ context: ResultContext) {
            didReceiveResultContext.send(context)
        }
    }

}
