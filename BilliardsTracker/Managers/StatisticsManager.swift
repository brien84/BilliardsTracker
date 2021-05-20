//
//  StatisticsManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-22.
//

import SwiftUI

final class StatisticsManager: ObservableObject {
    let drill: Drill
    private var afterDate: Date?

    init(drill: Drill, afterDate: Date? = nil) {
        self.drill = drill
        self.afterDate = afterDate
    }
    
    var results: [DrillResult] {
        if let afterDate = afterDate {
            return drill.results.filter { $0.date > afterDate }
        } else {
            return drill.results
        }
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

    var totalPottingPercentage: Int {
        guard results.count > 0 else { return 0 }

        return results.reduce(0, { $0 + $1.pottingPercentage }) / results.count
    }

    var chartDataPoints: [CGFloat] {
        results.reversed().map { CGFloat($0.potCount) / CGFloat(drill.attempts) }
    }
}
