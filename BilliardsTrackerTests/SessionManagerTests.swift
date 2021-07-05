//
//  SessionManagerTests.swift
//  BilliardsTrackerTests
//
//  Created by Marius on 2021-07-05.
//

import Combine
import XCTest
@testable import BilliardsTracker

final class SessionManagerTests: XCTestCase {
    var sut: SessionManager!

    override func setUpWithError() throws {
        sut = SessionManager()
    }

    override func tearDownWithError() throws {
        sut = nil
    }


}
