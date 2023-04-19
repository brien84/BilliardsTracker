//
//  SessionTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2023-04-19.
//

import ComposableArchitecture
import XCTest
@testable import BilliardsTracker

@MainActor
final class SessionTests: XCTestCase {
    func testAlertConfirmationBeforeExitingSession() async throws {
        let drill = PersistenceClient.mockDrill
        let store = TestStore(initialState: Session.State(drill: drill, startDate: .now), reducer: Session())

        await store.send(.didTapExitButton) {
            $0.alert = Session().exitConfirmationAlert
        }

        await store.send(.alertDidDismiss) {
            $0.alert = nil
        }
    }
}
