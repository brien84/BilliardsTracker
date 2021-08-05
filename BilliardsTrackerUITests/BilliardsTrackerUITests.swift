//
//  BilliardsTrackerUITests.swift
//  BilliardsTrackerUITests
//
//  Created by Marius on 2021-03-31.
//

import XCTest

final class BilliardsTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func startApp(data: Bool) {
        app = XCUIApplication()
        app.launchArguments = data ? ["ui-testing"] : ["ui-testing-no-data"]
        app.launch()
    }
}
