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

        // type title into textfield
        app.textFields.firstMatch.tap()
        app.textFields.firstMatch.typeText(title)

        // set attempts
        // slider adjusment behaviour changed on iOS15 and onwards
        if #available(iOS 16.0, *) {
            app.createDrillView_attemptsSlider.adjust(toNormalizedSliderPosition: CGFloat(attempts - 2) / 100.0)
        } else {
            app.createDrillView_attemptsSlider.adjust(toNormalizedSliderPosition: CGFloat(attempts - 1) / 100.0)
        }

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

        // type title into textfield
        app.textFields.firstMatch.tap()
        app.textFields.firstMatch.typeText(title)

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
        XCTAssertEqual(isFailable, app.drillView_failableIcon.isEnabled)
    }

    func testCreatingDrillEmptyInputs() throws {
        let title = ""
        let attempts = 0

        try! testOpeningCreateDrillViewWithNavigationButton()

        // type title into textfield
        app.textFields.firstMatch.tap()
        app.textFields.firstMatch.typeText(title)

        // set attempts
        app.createDrillView_attemptsSlider.adjust(toNormalizedSliderPosition: CGFloat(attempts) / 100.0)
        XCTAssertEqual(String(1), app.createDrillView_attemptsText.label)

        app.createDrillView_saveButton.tap()
        XCTAssertFalse(app.createDrillView.isHittable)

        XCTAssertTrue(app.drillView_titleText.waitForExistence(timeout: 1.0))
        XCTAssertEqual("DRILL TITLE", app.drillView_titleText.label)
        XCTAssertEqual("1", app.drillView_attemptsText.label)
        XCTAssertFalse(app.drillView_failableIcon.isEnabled)
    }

    // MARK: - SettingsView

    func testOpeningSettingsView() throws {
        startApp(data: true)

        app.mainView_settingsButton.tap()

        XCTAssertTrue(app.settingsView_titleText.waitForExistence(timeout: 1.0))
        XCTAssertTrue(app.settingsView_titleText.isHittable)
    }

    func testClosingSettingsView() throws {
        try! testOpeningSettingsView()

        app.mainView_settingsButton.tap()

        XCTAssertFalse(app.settingsView_titleText.isHittable)
    }

    func testClosingSettingsViewByClickingOutOfBounds() throws {
        try! testOpeningSettingsView()

        app.drillView_statisticsButton.firstMatch.tap()

        XCTAssertFalse(app.settingsView_titleText.isHittable)
    }

    func testSelectingSortOption() throws {
        try! testOpeningSettingsView()

        if !app.settingsView_attemptsImage.isEnabled {
            app.settingsView_attemptsText.tap()
            XCTAssertTrue(app.settingsView_attemptsImage.isEnabled)
        } else if !app.settingsView_titleImage.isEnabled {
            app.settingsView_titleText.tap()
            XCTAssertTrue(app.settingsView_titleImage.isEnabled)
        } else {
            XCTFail("Two or more options are selected at the same time.")
        }
    }

    // MARK: - StatisticsView

    func testOpeningStatisticsView() throws {
        startApp(data: true)

        app.drillView_statisticsButton.firstMatch.tap()

        XCTAssertTrue(app.statisticsView_toggleHistoryButton.exists)
    }

    func testClosingStatisticsView() throws {
        try! testOpeningStatisticsView()

        let backButton = app.navigationBars.firstMatch.buttons.firstMatch
        backButton.tap()

        XCTAssertFalse(app.statisticsView_toggleHistoryButton.exists)
    }

    func testTogglingBetweenChartAndResultsViews() throws {
        try! testOpeningStatisticsView()

        XCTAssertTrue(app.statisticsView_chartView.exists)
        XCTAssertFalse(app.statisticsView_resultsView.exists)

        app.statisticsView_toggleHistoryButton.tap()

        XCTAssertTrue(app.statisticsView_resultsView.exists)
        XCTAssertFalse(app.statisticsView_chartView.exists)
    }

    func testDrillWithNoResultsDisplaysNoDataLabel() throws {
        try! testCreatingDrill()

        XCTAssertFalse(app.statisticsView_noDataLabel.exists)

        app.drillView_statisticsButton.tap()

        XCTAssertTrue(app.statisticsView_noDataLabel.exists)
    }

    func testDrillWithNoResultsToggleButtonIsDisabled() throws {
        try! testCreatingDrill()

        app.drillView_statisticsButton.tap()

        XCTAssertTrue(app.statisticsView_toggleHistoryButton.exists)
        XCTAssertFalse(app.statisticsView_toggleHistoryButton.isEnabled)
    }

    func testDeletingDrill() throws {
        try! testCreatingDrill()

        app.drillView_statisticsButton.tap()

        XCTAssertTrue(app.statisticsView_deleteButton.exists)
        app.statisticsView_deleteButton.tap()

        let confirmationButton = app.alerts.firstMatch.buttons.element(boundBy: 1)
        confirmationButton.tap()

        XCTAssertFalse(app.statisticsView_deleteButton.isHittable)
        XCTAssertFalse(app.drillView_statisticsButton.exists)
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

    var mainView_settingsButton: XCUIElement {
        buttons["mainView_settingsButton"]
    }

    // MARK: - SettingsView

    var settingsView_attemptsText: XCUIElement {
        staticTexts["settingsView_attemptsText"]
    }

    var settingsView_titleText: XCUIElement {
        staticTexts["settingsView_titleText"]
    }

    var settingsView_attemptsImage: XCUIElement {
        images["settingsView_attemptsImage"]
    }

    var settingsView_titleImage: XCUIElement {
        images["settingsView_titleImage"]
    }

    // MARK: - StatisticsView

    var statisticsView_deleteButton: XCUIElement {
        buttons["statisticsView_deleteButton"]
    }

    var statisticsView_toggleHistoryButton: XCUIElement {
        buttons["statisticsView_toggleHistoryButton"]
    }

    var statisticsView_chartView: XCUIElement {
        staticTexts["statisticsView_chartView"]
    }

    var statisticsView_resultsView: XCUIElement {
        scrollViews["statisticsView_resultsView"]
    }

    var statisticsView_noDataLabel: XCUIElement {
        staticTexts["statisticsView_noDataLabel"]
    }

}
