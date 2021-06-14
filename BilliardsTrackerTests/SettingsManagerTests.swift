//
//  SettingsManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-06-14.
//

import XCTest
@testable import BilliardsTracker

final class SettingsManagerTests: XCTestCase {
    var sut: SettingsManager!

    override func setUpWithError() throws {
        sut = SettingsManager()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testExample() throws {
        
    }
}
