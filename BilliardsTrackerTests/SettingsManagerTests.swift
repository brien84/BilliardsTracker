//
//  SettingsManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-06-14.
//

import Combine
import XCTest
@testable import BilliardsTracker

final class SettingsManagerTests: XCTestCase {
    var sut: SettingsManager!
    var cancellables: Set<AnyCancellable>!
    var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        cancellables = []
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        sut = SettingsManager(userDefaults: userDefaults)
    }

    override func tearDownWithError() throws {
        sut = nil
        cancellables = nil
        userDefaults = nil
    }

    func testSetSortOptionIsSavedToUserDefaults() throws {
        var isInitialPublished = false

        let initialOption = sut.sortOption
        let newOption = SortOption.dateCreated

        let expectation = self.expectation(description: "sortOptionPublisher")

        userDefaults.sortOptionPublisher
            .sink { option in
                if isInitialPublished {
                    XCTAssertEqual(option, newOption)
                    expectation.fulfill()
                }

                if option == initialOption {
                    isInitialPublished = true
                }
            }
            .store(in: &cancellables)

        sut.sortOption = newOption

        waitForExpectations(timeout: 1)

        XCTAssertEqual(sut.sortOption, newOption)
    }
}
