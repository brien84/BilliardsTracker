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
        app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testUI() throws {
        closeOnboardView()
        openNewDrillViewByNavigationBarButton()
        cancelNewDrillView()
        openNewDrillViewByEmptyDrillPrompt()
        saveNewDrillView()
        openSessionView()
        closeSessionView()
        openDrillLogView()
        deleteDrill()
    }

    func closeOnboardView() {
        let element = app.buttons["Continue"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func openNewDrillViewByNavigationBarButton() {
        let element = app.navigationBars.buttons["Add"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func openNewDrillViewByEmptyDrillPrompt() {
        let element = app.buttons["Add Drill"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func cancelNewDrillView() {
        let element = app.buttons["Cancel"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func saveNewDrillView() {
        let textField = app.textFields["Drill Title"]
        textField.tap()
        textField.typeText("Test Drill")
        app.keyboards.firstMatch.buttons["return"].tap()

        app.staticTexts["Shots"].tap()
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "10")

        app.switches["Continuous"].tap()

        app.buttons["Save"].tap()
    }

    func openSessionView() {
        let element = app.staticTexts["TEST DRILL"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func closeSessionView() {
        let element = app.buttons["Close"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        let alert = app.alerts["Confirmation"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        alert.buttons["Yes"].tap()
        XCTAssertFalse(element.waitForExistence(timeout: 1.0))
    }

    func openDrillLogView() {
        let element = app.buttons["Open Drill Log"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func deleteDrill() {
        let element = app.buttons["Trash"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        let alert = app.alerts["Confirmation"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        alert.buttons["Delete"].tap()
        XCTAssertFalse(element.waitForExistence(timeout: 1.0))
    }
}
