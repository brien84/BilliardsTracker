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
