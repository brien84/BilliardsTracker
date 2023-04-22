//
//  BilliardsTrackerWatchAppUITests.swift
//  BilliardsTrackerWatchAppUITests
//
//  Created by Marius on 2023-04-20.
//

import XCTest

final class BilliardsTrackerWatchAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testUI() throws {

    }
}
