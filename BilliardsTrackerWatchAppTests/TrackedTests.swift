//
//  TrackedTests.swift
//  BilliardsTrackerWatchAppTests
//
//  Created by Marius on 2023-03-24.
//

//import ComposableArchitecture
//import XCTest
//@testable import BilliardsTrackerWatchApp
//
//@MainActor
//final class TrackedTests: XCTestCase {
//
//    func testStoppingSessionByTappingSessionStopButton() async throws {
//        let session = Session.State(title: "", shotCount: 9, isContinuous: true)
//
//        let store = TestStore(
//            initialState: Tracked.State(session: session),
//            reducer: Tracked()
//        )
//
//        await store.send(.session(.stopButtonDidTap)) {
//            $0.session = nil
//        }
//    }
//
//    func testStoppingSessionAfterGestureTrackingFailure() async throws {
//        let session = Session.State(title: "", shotCount: 9, isContinuous: true)
//
//        let store = TestStore(
//            initialState: Standalone.State(session: session),
//            reducer: Standalone()
//        )
//
//        await store.send(.session(.didDismissGestureTrackingError)) {
//            $0.session = nil
//        }
//    }
//
//    func testStoppingSessionByTappingResultDoneButton() async throws {
//        let result = Result.State(potCount: 6, missCount: 3)
//        let session = Session.State(result: result, title: "", shotCount: 9, isContinuous: true)
//
//        let store = TestStore(
//            initialState: Tracked.State(session: session),
//            reducer: Tracked()
//        )
//
//        store.dependencies.connectivityClient.sendResultContext = { _ in return () }
//
//        await store.send(.session(.result(.doneButtonDidTap))) {
//            $0.session = nil
//        }
//    }
//
//    func testNavigatingToSession() async throws {
//        let drillContext = DrillContext(isActive: true, isContinuous: true, shotCount: 9, title: "")
//
//        let store = TestStore(
//            initialState: Tracked.State(),
//            reducer: Tracked()
//        )
//
//        store.dependencies.connectivityClient.receiveDrillContext = {
//            AsyncStream { continuation in
//                continuation.yield(drillContext)
//            }
//        }
//
//        await store.send(.establishConnection)
//
//        await store.receive(.connectivityClientDidReceiveDrillContext(drillContext)) {
//            $0.session = Session.State(
//                title: drillContext.title,
//                shotCount: drillContext.shotCount,
//                isContinuous: drillContext.isContinuous
//            )
//        }
//
//        let drillContextX = DrillContext(isActive: false, isContinuous: true, shotCount: 9, title: "")
//
//        store.dependencies.connectivityClient.receiveDrillContext = {
//            AsyncStream { continuation in
//                continuation.yield(drillContextX)
//            }
//        }
//
//        await store.send(.establishConnection)
//
//        await store.receive(.connectivityClientDidReceiveDrillContext(drillContextX)) {
//            $0.session = nil
//        }
//
//        await store.send(.endConnection)
//    }
//
//}
