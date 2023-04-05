//
//  MainTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2023-02-11.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTracker

// swiftlint:disable type_body_length
@MainActor
final class MainTests: XCTestCase {

    var store: TestStore<Main.State, Main.Action, Main.State, Main.Action, ()>!

    override func setUp() async throws {
        store = TestStore(initialState: Main.State(), reducer: Main())
    }

    override func tearDown() async throws {
        store = nil
    }

    func testSuccessfullyNavigatingToSessionAndReceivingResult() async throws {
        let drill = PersistenceClient.mockDrill
        let testDate = Date(timeIntervalSince1970: .zero)
        let result = ResultContext(potCount: 10, missCount: 10, date: testDate)

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.date.now = testDate

        store.dependencies.connectivityClient.sendDrillContext = { @Sendable _ in .success }
        store.dependencies.connectivityClient.receiveResults = { @Sendable in
            AsyncStream<ResultContext> {
                try? await mainQueue.sleep(for: .seconds(10))
                return result
            }
        }

        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didLoad([drill]) }
        store.dependencies.persistenceClient.insertResult = { @Sendable _, _ in .didSucceed }

        store.dependencies.userDefaults.getSortOption = { @Sendable in .title }
        store.dependencies.userDefaults.getSortOrder = { @Sendable in .forward }

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
            $0.session = Session.State(drill: drill, startDate: testDate)
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

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        let testDate = Date(timeIntervalSince1970: .zero)
        store.dependencies.date.now = testDate

        store.dependencies.connectivityClient.sendDrillContext = { _ in .failure(.notReachable) }

        await store.send(.drillList(.drillItem(id: drill.id, action: .didSelectDrill))) {
            $0.isShowingLoadingIndicator = true
            $0.session = Session.State(drill: drill, startDate: testDate)
        }

        await mainQueue.advance(by: .milliseconds(500))

        await store.receive(.connectivityClientDidReceiveResponse(.failure(.notReachable))) {
            $0.isShowingLoadingIndicator = false
            $0.alert = AlertState {
                TextState("Watch app is not reachable!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Make sure BilliardsTracker Watch app is installed and running.")
            }
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

        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        let testDate = Date(timeIntervalSince1970: .zero)
        store.dependencies.date.now = testDate

        store.dependencies.connectivityClient.sendDrillContext = { _ in .failure(.notReady) }

        await store.send(.drillList(.drillItem(id: drill.id, action: .didSelectDrill))) {
            $0.isShowingLoadingIndicator = true
            $0.session = Session.State(drill: drill, startDate: testDate)
        }

        await mainQueue.advance(by: .milliseconds(500))

        await store.receive(.connectivityClientDidReceiveResponse(.failure(.notReady))) {
            $0.isShowingLoadingIndicator = false

            $0.alert = AlertState {
                TextState("Watch app is not in Tracked mode!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Make sure Tracked mode is selected in Watch app.")
            }
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
            $0.alert = AlertState {
                TextState("Something went wrong!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Latest changes will not be saved.")
            }
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

        await store.send(.drillList(.drillItem(id: drill.id, action: .didTapStatisticsButton))) {
            $0.statistics = Statistics.State(drill: drill)
            $0.isNavigationToStatisticsActive = true
        }

        await store.send(.statistics(.didTapDeleteButton)) {
            $0.isNavigationToStatisticsActive = false
        }

        await store.receive(.persistenceClient(.didSucceed))
        await store.receive(.persistenceClient(.didLoad([]))) {
            $0.drillList = DrillList.State(drills: [])
        }
    }

    func testFailingToLoadDrills() async throws {
        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.connectivityClient.receiveResults = { @Sendable in AsyncStream<ResultContext> { _ in } }
        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didFail(.loading) }
        store.dependencies.userDefaults.getSortOption = { @Sendable in .title }
        store.dependencies.userDefaults.getSortOrder = { @Sendable in .forward }

        await store.send(.onAppear) {
            $0.isShowingLoadingIndicator = true
        }

        await mainQueue.advance(by: .milliseconds(250))

        await store.receive(.persistenceClient(.didFail(.loading))) {
            $0.alert = AlertState {
                TextState("Something went wrong!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
            }
        }

        await store.send(.alertDidDismiss) {
            $0.alert = nil
        }

        await store.skipInFlightEffects()
    }

    func testFailingToInitializePersistenceClient() async throws {
        let mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()

        store.dependencies.connectivityClient.receiveResults = { @Sendable in AsyncStream<ResultContext> { _ in } }
        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didFail(.initialization) }
        store.dependencies.userDefaults.getSortOption = { @Sendable in .title }
        store.dependencies.userDefaults.getSortOrder = { @Sendable in .forward }

        await store.send(.onAppear) {
            $0.isShowingLoadingIndicator = true
        }

        await mainQueue.advance(by: .milliseconds(250))

        await store.receive(.persistenceClient(.didFail(.initialization))) {
            $0.alert = AlertState {
                TextState("Something went terribly wrong!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
            }
        }

        await store.skipInFlightEffects()
    }

    func testSortingDrills() async throws {
        let drill0 = PersistenceClient.mockDrill
        drill0.title = "Z"
        drill0.shotCount = 1
        let drill1 = PersistenceClient.mockDrill
        drill1.title = "A"
        drill1.shotCount = 10

        let settings = Settings.State(sortOption: .dateCreated, sortOrder: .forward)

        // sorted by earliest `dateCreated`:
        let drillList = DrillList.State(drills: [drill1, drill0])
        let main = Main.State(drillList: drillList, settings: settings)

        let store = TestStore(initialState: main, reducer: Main())

        let userDefaults = { UserDefaults(suiteName: "UserDefaultsClient.tests")! }
        userDefaults().removePersistentDomain(forName: "UserDefaultsClient.tests")

        store.dependencies.userDefaults = UserDefaultsClient(
            getSortOption: {
                let rawValue = userDefaults().integer(forKey: "sortOptionKey")
                return SortOption(rawValue: rawValue) ?? .title
            },
            setSortOption: { option in
                userDefaults().set(option.rawValue, forKey: "sortOptionKey")
            },
            getSortOrder: {
                let rawValue = userDefaults().bool(forKey: "sortOrderKey")
                return rawValue ? .forward : .reverse
            },
            setSortOrder: { order in
                userDefaults().set(order == .forward, forKey: "sortOrderKey")
            }
        )

        await store.send(.settings(.didSelectSortOption(.title))) {
            // sorted by descending `title`:
            $0.drillList = DrillList.State(drills: [drill1, drill0])
            $0.settings.sortOption = .title
        }

        await store.send(.settings(.didSelectSortOrder(.reverse))) {
            // sorted by ascending `title`:
            $0.drillList = DrillList.State(drills: [drill0, drill1])
            $0.settings.sortOrder = .reverse
        }

        await store.send(.settings(.didSelectSortOption(.shotCount))) {
            // sorted by ascending `shotCount`:
            $0.drillList = DrillList.State(drills: [drill1, drill0])
            $0.settings.sortOption = .shotCount
        }
    }
}
