//
//  StoreManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-07-05.
//

import Combine
import XCTest
@testable import BilliardsTracker

final class StoreManagerTests: XCTestCase {
    var sut: StoreManager!

    override func setUpWithError() throws {
        sut = StoreManager()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
}
