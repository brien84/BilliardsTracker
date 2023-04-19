//
//  IntegrationTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2023-04-18.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTracker

@MainActor
final class IntegrationTests: XCTestCase {
    var store: TestStore<Main.State, Main.Action, Main.State, Main.Action, ()>!
    var mainQueue: TestSchedulerOf<DispatchQueue>!
    let now = Date(timeIntervalSince1970: .zero)

    override func setUp() async throws {
        store = TestStore(initialState: Main.State(), reducer: Main())

        store.dependencies.connectivityClient.receiveResults = { @Sendable in AsyncStream<ResultContext> { _ in } }
        store.dependencies.date.now = now
        mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()
        store.dependencies.userDefaults.getAppearance = { @Sendable in .system }
        store.dependencies.userDefaults.setAppearance = { @Sendable _ in }
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in true }
        store.dependencies.userDefaults.getSortOption = { @Sendable in .title }
        store.dependencies.userDefaults.setSortOption = { @Sendable _ in }
        store.dependencies.userDefaults.getSortOrder = { @Sendable in .forward }
        store.dependencies.userDefaults.setSortOrder = { @Sendable _ in }
    }

    override func tearDown() async throws {
        mainQueue = nil
        store = nil
    }

    func testSuccessfullyNavigatingToSessionAndReceivingResults() async throws {
        let drill = PersistenceClient.mockDrill
        let result = ResultContext(potCount: 10, missCount: 10, date: now)

        store.dependencies.connectivityClient.sendDrillContext = { @Sendable _ in .success }
        store.dependencies.connectivityClient.receiveResults = { @Sendable in
            AsyncStream<ResultContext> {
                try? await self.mainQueue.sleep(for: .seconds(10))
                return result
            }
        }

        store.dependencies.persistenceClient.insertResult = { @Sendable _, _ in .didSucceed }
        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didLoad([drill]) }

        await store.send(.onAppear) {
            $0.isShowingLoadingIndicator = true
        }

        await mainQueue.advance(by: .milliseconds(250))

        await store.receive(.persistenceClient(.didLoad([drill]))) {
            $0.isShowingLoadingIndicator = false
            $0.drillList = DrillList.State(drills: [drill])
        }

        await store.send(.drillList(.drillItem(id: drill.id, action: .didSelectDrill))) {
            $0.isShowingLoadingIndicator = true
            $0.session = Session.State(drill: drill, startDate: self.now)
        }

        await mainQueue.advance(by: .milliseconds(500))

        await store.receive(.connectivityClientDidReceiveResponse(.success)) {
            $0.isShowingLoadingIndicator = false
            $0.isNavigationToSessionActive = true
        }

        await mainQueue.advance(by: .seconds(15))

        await store.receive(.connectivityClientDidReceiveResult(result))
        await store.receive(.persistenceClient(.didSucceed))
        await store.receive(.persistenceClient(.didLoad([drill])))

        await store.send(.session(.sessionDidExit)) {
            $0.isNavigationToSessionActive = false
        }

        await store.skipInFlightEffects()
    }

    func testFailingNavigationToSessionWhenWatchIsNotReachable() async throws {
        let drill = PersistenceClient.mockDrill
        let drillList = DrillList.State(drills: [drill])
        let main = Main.State(drillList: drillList)

        let store = TestStore(initialState: main, reducer: Main())

        store.dependencies.connectivityClient.sendDrillContext = { _ in .failure(.notReachable) }
        store.dependencies.date.now = now
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        await store.send(.drillList(.drillItem(id: drill.id, action: .didSelectDrill))) {
            $0.isShowingLoadingIndicator = true
            $0.session = Session.State(drill: drill, startDate: self.now)
        }

        await mainQueue.advance(by: .milliseconds(500))

        await store.receive(.connectivityClientDidReceiveResponse(.failure(.notReachable))) {
            $0.isShowingLoadingIndicator = false
            $0.alert = Main().notReachableAlert
        }

        await store.send(.alertDidDismiss) {
            $0.alert = nil
        }
    }

    func testFailingNavigationToSessionWhenWatchIsNotReady() async throws {
        let drill = PersistenceClient.mockDrill
        let drillList = DrillList.State(drills: [drill])
        let main = Main.State(drillList: drillList)

        let store = TestStore(initialState: main, reducer: Main())

        store.dependencies.connectivityClient.sendDrillContext = { _ in .failure(.notReady) }
        store.dependencies.date.now = now
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        await store.send(.drillList(.drillItem(id: drill.id, action: .didSelectDrill))) {
            $0.isShowingLoadingIndicator = true
            $0.session = Session.State(drill: drill, startDate: self.now)
        }

        await mainQueue.advance(by: .milliseconds(500))

        await store.receive(.connectivityClientDidReceiveResponse(.failure(.notReady))) {
            $0.isShowingLoadingIndicator = false
            $0.alert = Main().notReadyAlert
        }

        await store.send(.alertDidDismiss) {
            $0.alert = nil
        }
    }

    func testNavigatingToNewDrillAndThenCancelling() async throws {
        await store.send(.binding(.set(\.$isNavigationToNewDrillActive, true))) {
            $0.isNavigationToNewDrillActive = true
            $0.newDrill = NewDrill.State()
        }

        await store.send(.newDrill(.cancelButtonDidTap)) {
            $0.isNavigationToNewDrillActive = false
        }

        await store.send(.drillList(.didTapNewDrillButton)) {
            $0.isNavigationToNewDrillActive = true
            $0.newDrill = NewDrill.State()
        }

        await store.send(.newDrill(.cancelButtonDidTap)) {
            $0.isNavigationToNewDrillActive = false
        }
    }

    func testSavingNewDrill() async throws {
        let drill = PersistenceClient.mockDrill
        drill.isContinuous = false
        drill.shotCount = 15

        store.dependencies.persistenceClient.createDrill = { @Sendable _ in .didSucceed }
        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didLoad([drill]) }

        await store.send(.binding(.set(\.$isNavigationToNewDrillActive, true))) {
            $0.isNavigationToNewDrillActive = true
            $0.newDrill = NewDrill.State()
        }

        await store.send(.newDrill(.binding(.set(\.$isContinuous, drill.isContinuous)))) {
            $0.newDrill.isContinuous = drill.isContinuous
        }

        await store.send(.newDrill(.binding(.set(\.$shotCount, drill.shotCount)))) {
            $0.newDrill.shotCount = drill.shotCount
        }

        await store.send(.newDrill(.binding(.set(\.$title, drill.title)))) {
            $0.newDrill.title = drill.title
        }

        await store.send(.newDrill(.saveButtonDidTap)) {
            $0.isNavigationToNewDrillActive = false
        }

        await store.receive(.persistenceClient(.didSucceed))
        await store.receive(.persistenceClient(.didLoad([drill]))) {
            $0.drillList = DrillList.State(drills: [drill])
        }
    }

    func testFailingToSaveNewDrill() async throws {
        _ = try? PersistentStore(inMemory: true)
        store.dependencies.persistenceClient.createDrill = { @Sendable _ in .didFail(.saving) }

        await store.send(.binding(.set(\.$isNavigationToNewDrillActive, true))) {
            $0.isNavigationToNewDrillActive = true
            $0.newDrill = NewDrill.State()
        }

        await store.send(.newDrill(.saveButtonDidTap)) {
            $0.isNavigationToNewDrillActive = false
        }

        await store.receive(.persistenceClient(.didFail(.saving))) {
            $0.alert = Main().savingAlert
        }

        await store.send(.alertDidDismiss) {
            $0.alert = nil
        }
    }

    func testDeletingDrill() async throws {
        let drill = PersistenceClient.mockDrill
        let drillList = DrillList.State(drills: [drill])
        let main = Main.State(drillList: drillList)

        let store = TestStore(initialState: main, reducer: Main())
        store.dependencies.persistenceClient.deleteDrill = { _ in .didSucceed }
        store.dependencies.persistenceClient.loadDrills = { .didLoad([]) }

        await store.send(.drillList(.drillItem(id: drill.id, action: .didPressDrillLogButton))) {
            $0.drillLog = DrillLog.State(drill: drill)
            $0.isNavigationToDrillLogActive = true
        }

        await store.send(.drillLog(.didDeleteDrill)) {
            $0.isNavigationToDrillLogActive = false
        }

        await store.receive(.persistenceClient(.didSucceed))
        await store.receive(.persistenceClient(.didLoad([]))) {
            $0.drillList = DrillList.State(drills: [])
        }
    }

    func testSortingDrills() async throws {
        let drill0 = PersistenceClient.mockDrill
        drill0.title = "Z"
        drill0.shotCount = 1
        let drill1 = PersistenceClient.mockDrill
        drill1.title = "A"
        drill1.shotCount = 10

        let drillList = DrillList.State(drills: [drill0, drill1])
        let main = Main.State(drillList: drillList)
        let localStore = TestStore(initialState: main, reducer: Main())
        localStore.dependencies = store.dependencies

        await localStore.send(.settings(.didSelectSortOption(.title))) {
            // sorted by descending `title`
            $0.drillList = DrillList.State(drills: [drill1, drill0])
            $0.settings.sortOption = .title
        }

        await localStore.send(.settings(.didSelectSortOrder(.reverse))) {
            // sorted by ascending `title`
            $0.drillList = DrillList.State(drills: [drill0, drill1])
            $0.settings.sortOrder = .reverse
        }

        await localStore.send(.settings(.didSelectSortOption(.shotCount))) {
            // sorted by ascending `shotCount`
            $0.drillList = DrillList.State(drills: [drill1, drill0])
            $0.settings.sortOption = .shotCount
        }
    }
}
