//
//  DrillRunner.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import Foundation

enum HitType {
    case pot
    case miss
}

final class DrillRunner: ObservableObject {
    private let attempts = 10

    var remainingAttempts: Int {
        attempts - potCount - missCount
    }

    @Published private(set) var potCount = 0
    @Published private(set) var missCount = 0

    @Published private(set) var isCompleted = false

    func add(_ hit: HitType) {
        switch hit {
        case .pot:
            potCount += 1
        case .miss:
            missCount += 1
        }

        if remainingAttempts == 0 {
            isCompleted = true
        }
    }
}
