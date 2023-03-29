//
//  MainTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2023-02-11.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTracker

@MainActor
final class MainTests: XCTestCase {

    var store: TestStore<Main.State, Main.Action, Main.State, Main.Action, ()>!

    override func setUp() async throws {
        store = TestStore(initialState: Main.State(), reducer: Main())
    }

    override func tearDown() async throws {
        store = nil
    }

    func testNavigatingToNewDrillAndThenCancelling() async throws {
        await store.send(.binding(.set(\.$isNavigationToNewDrillActive, true))) {
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
}
