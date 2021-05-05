//
//  StatisticsManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-22.
//

import Foundation

struct StatisticsManager {
    private let drill: Drill
    
    var results: [DrillResult] {
        drill.results
    }

    var totalAttempts: Int {
        results.reduce(0, { $0 + $1.potCount + $1.missCount })
    }

    var totalPotCount: Int {
        results.reduce(0, { $0 + $1.potCount })
    }

    var totalMissCount: Int {
        results.reduce(0, { $0 + $1.missCount })
    }

    var pottingPercentage: Int {
        guard totalAttempts > 0 else { return 0 }

        return Int(Double(totalPotCount) / Double(totalAttempts) * 100)
    }

    init(drill: Drill) {
        self.drill = drill
    }
}
