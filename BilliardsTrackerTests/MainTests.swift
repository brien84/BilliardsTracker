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

    func test() async {
        let store = TestStore(
            initialState: Main.State(),
            reducer: Main()
        )
    }

}
