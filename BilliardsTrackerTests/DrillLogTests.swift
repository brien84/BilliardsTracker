//
//  DrillLogTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2023-04-19.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTracker

@MainActor
final class DrillLogTests: XCTestCase {
    func testOpeningAndClosingFullHistoryView() async throws {
        let drill = PersistenceClient.mockDrill
        let store = TestStore(initialState: DrillLog.State(drill: drill), reducer: DrillLog())

        await store.send(.didPressShowFullHistoryButton) {
            $0.isNavigationToFullHistoryActive = true
        }

        await store.send(.didPressExitFullHistoryButton) {
            $0.isNavigationToFullHistoryActive = false
        }
    }

    func testAlertConfirmationBeforeDeletingDrill() async throws {
        let drill = PersistenceClient.mockDrill
        let store = TestStore(initialState: DrillLog.State(drill: drill), reducer: DrillLog())

        await store.send(.didPressDeleteButton) {
            $0.alert = DrillLog().deletionAlert
        }

        await store.send(.alertDidDismiss) {
            $0.alert = nil
        }
    }
}
