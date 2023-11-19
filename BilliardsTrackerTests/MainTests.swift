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
    var mainQueue: TestSchedulerOf<DispatchQueue>!

    override func setUp() async throws {
        store = TestStore(initialState: Main.State(), reducer: Main())

        store.dependencies.connectivityClient.receiveResults = { @Sendable in AsyncStream<ResultContext> { _ in } }
        mainQueue = DispatchQueue.test
        store.dependencies.mainQueue = mainQueue.eraseToAnyScheduler()
        store.dependencies.userDefaults.getAppearance = { @Sendable in .system }
        store.dependencies.userDefaults.setAppVersion = { @Sendable in }
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in true }
        store.dependencies.userDefaults.setHasOnboardBeenShown = { @Sendable _ in }
        store.dependencies.userDefaults.getSortOption = { @Sendable in .title }
        store.dependencies.userDefaults.getSortOrder = { @Sendable in .forward }
    }

    override func tearDown() async throws {
        mainQueue = nil
        store = nil
    }

    func testNavigationToOnboardView() async throws {
        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didLoad([]) }
        store.dependencies.userDefaults.getHasOnboardBeenShown = { @Sendable in false }

        await store.send(.onAppear) {
            $0.isShowingLoadingIndicator = true
            $0.isNavigationToOnboardActive = true
        }

        await store.send(.didDismissOnboardView) {
            $0.isNavigationToOnboardActive = false
        }

        await store.skipInFlightEffects()
    }

    func testLoadingDrills() async throws {
        let drills = [
            PersistenceClient.mockDrill,
            PersistenceClient.mockDrill,
            PersistenceClient.mockDrill
        ]

        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didLoad(drills) }

        await store.send(.onAppear) {
            $0.isShowingLoadingIndicator = true
        }

        await mainQueue.advance(by: .milliseconds(250))

        await store.receive(.persistenceClient(.didLoad(drills))) {
            $0.isShowingLoadingIndicator = false
            let sortedDrills = drills.sorted(using: $0.settings.sortDescriptor)
            $0.drillList = DrillList.State(drills: sortedDrills)
        }

        await store.skipInFlightEffects()
    }

    func testFailingToLoadDrills() async throws {
        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didFail(.loading) }

        await store.send(.onAppear) {
            $0.isShowingLoadingIndicator = true
        }

        await mainQueue.advance(by: .milliseconds(250))

        await store.receive(.persistenceClient(.didFail(.loading))) {
            $0.alert = Main().loadingAlert
        }

        await store.send(.alertDidDismiss) {
            $0.alert = nil
        }

        await store.skipInFlightEffects()
    }

    func testFailingToInitializePersistenceClient() async throws {
        store.dependencies.persistenceClient.loadDrills = { @Sendable in .didFail(.initialization) }

        await store.send(.onAppear) {
            $0.isShowingLoadingIndicator = true
        }

        await mainQueue.advance(by: .milliseconds(500))

        await store.receive(.persistenceClient(.didFail(.initialization))) {
            $0.alert = Main().initializationAlert
        }

        await store.skipInFlightEffects()
    }
}
