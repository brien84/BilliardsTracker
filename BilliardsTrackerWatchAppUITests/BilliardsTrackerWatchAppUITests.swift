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
        closeOnboardView()
        openStandaloneSetupView()
        startStandaloneSession()
        registerShots()
        pauseAndResumeSession()
        stopSession()
        closeSessionSetupView()

        closeOnboardView()
        openTrackedSetupView()
        completeAndRestartSession()
        completeAndFinishSession()
    }

    func closeOnboardView() {
        XCTAssertTrue(app.staticTexts["Flick your wrist back and forth to register potted ball"].exists)
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Flick your arm up and down to register missed ball"].exists)

        let element = app.buttons["BackButton"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func openStandaloneSetupView() {
        let element = app.buttons["Standalone"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func openTrackedSetupView() {
        app.swipeLeft()
        let element = app.buttons["Tracked"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func closeSessionSetupView() {
        let element = app.buttons["BackButton"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func startStandaloneSession() {
        let picker = app.otherElements["Set Shots"]
        XCTAssertTrue(picker.waitForExistence(timeout: 1.0))
        picker.swipeUp()

        let button = app.buttons["Start"]
        XCTAssertTrue(button.waitForExistence(timeout: 1.0))
        button.tap()
    }

    func stopSession() {
        app.swipeLeft()
        let stopButton = app.buttons["Stop Session"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 1.0))
        stopButton.tap()
    }

    func pauseAndResumeSession() {
        app.swipeLeft()
        let pauseButton = app.buttons["Pause Session"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 1.0))
        pauseButton.tap()

        app.swipeLeft()
        let resumeButton = app.buttons["Resume Session"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 1.0))
        resumeButton.tap()
    }

    func completeAndRestartSession() {
        let potButton = app.buttons["Register Potted Ball"]
        XCTAssertTrue(potButton.waitForExistence(timeout: 1.0))
        potButton.tap()

        let restartButton = app.buttons["Restart"]
        XCTAssertTrue(restartButton.waitForExistence(timeout: 1.0))
        restartButton.tap()
    }

    func completeAndFinishSession() {
        let potButton = app.buttons["Register Potted Ball"]
        XCTAssertTrue(potButton.waitForExistence(timeout: 1.0))
        potButton.tap()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 1.0))
        doneButton.tap()
    }

    func registerShots() {
        let indicator = app.progressIndicators.firstMatch
        XCTAssertTrue(indicator.waitForExistence(timeout: 1.0))
        XCTAssertEqual(indicator.value as? String, "100%")

        let potButton = app.buttons["Register Potted Ball"]
        XCTAssertTrue(potButton.waitForExistence(timeout: 1.0))
        potButton.tap()
        XCTAssertNotEqual(indicator.value as? String, "100%")

        app.swipeLeft()
        let undoButton = app.buttons["Undo Session"]
        XCTAssertTrue(undoButton.waitForExistence(timeout: 1.0))
        undoButton.tap()
        XCTAssertEqual(indicator.value as? String, "100%")

        let missButton = app.buttons["Register Missed Ball"]
        XCTAssertTrue(missButton.waitForExistence(timeout: 1.0))
        missButton.tap()
        XCTAssertNotEqual(indicator.value as? String, "100%")
    }
}
