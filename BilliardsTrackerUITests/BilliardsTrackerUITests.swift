//
//  BilliardsTrackerUITests.swift
//  BilliardsTrackerUITests
//
//  Created by Marius on 2021-03-31.
//

import XCTest

// swiftlint:disable force_try
// swiftlint:disable identifier_name
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

    // MARK: - CreateDrillView

    func testOpeningCreateDrillViewWithNavigationButton() throws {
        startApp(data: false)

        XCTAssertTrue(app.mainView.waitForExistence(timeout: 1.0))

        app.mainView_createDrillButtonNavigation.tap()

        XCTAssertTrue(app.createDrillView.waitForExistence(timeout: 1.0))
    }

    func testOpeningCreateDrillViewWithBackgroundButton() throws {
        startApp(data: false)

        XCTAssertTrue(app.mainView.waitForExistence(timeout: 1.0))

        app.mainView_createDrillButtonBackground.tap()

        XCTAssertTrue(app.createDrillView.waitForExistence(timeout: 1.0))
    }

    func testClosingCreateDrillView() throws {
        try! testOpeningCreateDrillViewWithNavigationButton()

        app.createDrillView_cancelButton.tap()

        XCTAssertFalse(app.createDrillView.isHittable)
    }

    func testTogglingCreateDrillFailableHelpView() throws {
        try! testOpeningCreateDrillViewWithNavigationButton()

        app.createDrillView_infoButton.tap()
        XCTAssertTrue(app.createDrillView_failableHelpView.isHittable)

        app.createDrillView_infoButton.tap()
        XCTAssertFalse(app.createDrillView_failableHelpView.isHittable)

        app.createDrillView_infoButton.tap()
        XCTAssertTrue(app.createDrillView_failableHelpView.isHittable)

        app.createDrillView_failableHelpView.tap()
        XCTAssertFalse(app.createDrillView_failableHelpView.isHittable)
    }

    func testCreatingDrill() throws {
        let title = "testTitle"
        let attempts = 30
        let isFailable = true

        try! testOpeningCreateDrillViewWithNavigationButton()

        // type title
        app.createDrillView_titleField.tap()
        app.createDrillView_titleField.typeText(title)

        // set attempts
        app.createDrillView_attemptsSlider.adjust(toNormalizedSliderPosition: CGFloat(attempts) / 100.0)
        XCTAssertEqual(String(attempts), app.createDrillView_attemptsText.label)

        // toggle isFailable
        app.createDrillView_failableToggle.tap()

        app.createDrillView_saveButton.tap()
        XCTAssertFalse(app.createDrillView.isHittable)

        XCTAssertTrue(app.drillView_titleText.waitForExistence(timeout: 1.0))
        XCTAssertEqual(title.uppercased(), app.drillView_titleText.label)
        XCTAssertEqual(String(attempts), app.drillView_attemptsText.label)
        XCTAssertEqual(isFailable, app.drillView_failableIcon.isHittable)
    }

    func testCreatingDrillLargeInputs() throws {
        let title = String(repeating: "a", count: 500)
        let attempts = 100
        let isFailable = true

        try! testOpeningCreateDrillViewWithNavigationButton()

        // type title
        app.createDrillView_titleField.tap()
        app.createDrillView_titleField.typeText(title)

        // set attempts
        app.createDrillView_attemptsSlider.adjust(toNormalizedSliderPosition: CGFloat(attempts) / 100.0)
        XCTAssertEqual(String(attempts), app.createDrillView_attemptsText.label)

        // toggle isFailable
        app.createDrillView_failableToggle.tap()

        app.createDrillView_saveButton.tap()
        XCTAssertFalse(app.createDrillView.isHittable)

        XCTAssertTrue(app.drillView_titleText.waitForExistence(timeout: 1.0))
        XCTAssertEqual(title.uppercased(), app.drillView_titleText.label)
        XCTAssertEqual(String(attempts), app.drillView_attemptsText.label)
        XCTAssertEqual(isFailable, app.drillView_failableIcon.isHittable)
    }

    func testCreatingDrillEmptyInputs() throws {
        let title = ""
        let attempts = 0

        try! testOpeningCreateDrillViewWithNavigationButton()

        // type title
        app.createDrillView_titleField.tap()
        app.createDrillView_titleField.typeText(title)

        // set attempts
        app.createDrillView_attemptsSlider.adjust(toNormalizedSliderPosition: CGFloat(attempts) / 100.0)
        XCTAssertEqual(String(1), app.createDrillView_attemptsText.label)

        app.createDrillView_saveButton.tap()
        XCTAssertFalse(app.createDrillView.isHittable)

        XCTAssertTrue(app.drillView_titleText.waitForExistence(timeout: 1.0))
        XCTAssertEqual("DRILL TITLE", app.drillView_titleText.label)
        XCTAssertEqual("1", app.drillView_attemptsText.label)
        XCTAssertFalse(app.drillView_failableIcon.isHittable)
    }

}

extension XCUIApplication {

    // MARK: - CreateDrillView

    var createDrillView: XCUIElement {
        otherElements["createDrillView"]
    }

    var createDrillView_cancelButton: XCUIElement {
        buttons["createDrillView_cancelButton"]
    }

    var createDrillView_saveButton: XCUIElement {
        buttons["createDrillView_saveButton"]
    }

    var createDrillView_titleField: XCUIElement {
        textFields["createDrillView_titleField"]
    }

    var createDrillView_attemptsSlider: XCUIElement {
        sliders["createDrillView_attemptsSlider"]
    }

    var createDrillView_attemptsText: XCUIElement {
        staticTexts["createDrillView_attemptsText"]
    }

    var createDrillView_infoButton: XCUIElement {
        buttons["createDrillView_infoButton"]
    }

    var createDrillView_failableHelpView: XCUIElement {
        staticTexts["createDrillView_failableHelpView"]
    }

    var createDrillView_failableToggle: XCUIElement {
        switches["createDrillView_failableToggle"]
    }

    // MARK: - DrillView

    var drillView_attemptsText: XCUIElement {
        staticTexts["drillView_attemptsText"]
    }

    var drillView_titleText: XCUIElement {
        staticTexts["drillView_titleText"]
    }

    var drillView_failableIcon: XCUIElement {
        images["drillView_failableIcon"]
    }

    var drillView_statisticsButton: XCUIElement {
        buttons["drillView_statisticsButton"]
    }

    // MARK: - MainView

    var mainView: XCUIElement {
        otherElements["mainView"]
    }

    var mainView_createDrillButtonBackground: XCUIElement {
        buttons["mainView_createDrillButtonBackground"]
    }

    var mainView_createDrillButtonNavigation: XCUIElement {
        buttons["mainView_createDrillButtonNavigation"]
    }

}
