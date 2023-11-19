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
        configureStandaloneSession()
        startStandaloneSession()
        registerShots()
        pauseAndResumeSession()
        stopSession()

        configureTrackedSession()
        openTrackedActivationView()
        completeAndRestartSession()
        completeAndFinishSession()
    }

    func closeOnboardView() {
        XCTAssertTrue(app.images["Animations/PotGesture/overlay"].exists)
        app.swipeLeft()
        XCTAssertTrue(app.images["Animations/MissGesture/overlay"].exists)
        app.swipeLeft()
        XCTAssertTrue(app.images["Animations/BridgeHand/overlay"].exists)

        let element = app.buttons["BackButton"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func openTrackedActivationView() {
        let element = app.cells.allElementsBoundByIndex.first { $0.label.contains("Tracked") }!
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func startStandaloneSession() {
        let element = app.cells.allElementsBoundByIndex.first { $0.label.contains("Standalone") }!
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()
    }

    func configureStandaloneSession() {
        let element = app.buttons["More"].firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        changeShotCount()
        toggleContinuous()
        toggleRestarting()
        toggleContinuous()
        toggleGestures()

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 1.0))
        backButton.tap()
    }

    func configureTrackedSession() {
        let parent = app.cells.allElementsBoundByIndex.first { $0.label.contains("Tracked") }!
        let element = parent.buttons["More"]
        XCTAssertTrue(element.waitForExistence(timeout: 1.0))
        element.tap()

        toggleGestures()

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 1.0))
        backButton.tap()
    }

    func changeShotCount() {
        let shotCountButton = app.cells.allElementsBoundByIndex.first { $0.label.contains("Shot Count") }!
        XCTAssertTrue(shotCountButton.waitForExistence(timeout: 1.0))
        shotCountButton.tap()

        let picker = app.otherElements["Shot Count"]
        XCTAssertTrue(picker.waitForExistence(timeout: 1.0))
        picker.swipeUp(velocity: .fast)

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 1.0))
        doneButton.tap()
    }

    func toggleContinuous() {
        let continuousButton = app.cells.allElementsBoundByIndex.first { $0.label.contains("Continuous") }!
        XCTAssertTrue(continuousButton.waitForExistence(timeout: 1.0))
        continuousButton.tap()

        let toggle = app.switches["Continuous"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 1.0))
        toggle.tap()

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 1.0))
        backButton.tap()
    }

    func toggleRestarting() {
        let continuousButton = app.cells.allElementsBoundByIndex.first { $0.label.contains("Restarting") }!
        XCTAssertTrue(continuousButton.waitForExistence(timeout: 1.0))
        continuousButton.tap()

        let toggle = app.switches["Restarting"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 1.0))
        toggle.tap()

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 1.0))
        backButton.tap()
    }

    func toggleGestures() {
        app.swipeUp()

        let restartingButton = app.cells.allElementsBoundByIndex.first { $0.label.contains("Gestures") }!
        XCTAssertTrue(restartingButton.waitForExistence(timeout: 1.0))
        restartingButton.tap()

        let toggle = app.switches["Gesture Recognition"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 1.0))
        toggle.tap()

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 1.0))
        backButton.tap()
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
