//
//  DrillRunner.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Foundation

final class DrillRunner: ObservableObject {
    private let attempts = 100

    var remainingAttempts: Int {
        attempts - potCount - missCount
    }

    @Published private(set) var potCount = 0
    @Published private(set) var missCount = 0

    func addPot() {
        potCount += 1
    }

    func addMiss() {
        missCount += 1
    }
}
