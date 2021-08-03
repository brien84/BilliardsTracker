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

    var attemptsCount: Int {
        results.reduce(0, { $0 + $1.potCount + $1.missCount })
    }

    var potCount: Int {
        results.reduce(0, { $0 + $1.potCount })
    }

    var missCount: Int {
        results.reduce(0, { $0 + $1.missCount })
    }

    var averagePots: Double {
        guard results.count > 0 else { return 0 }

        let result = Double(potCount) / Double(results.count)

        return floor(result * 10) / 10.0
    }

    var pottingPercentage: Int {
        guard results.count > 0 else { return 0 }

        return results.reduce(0, { $0 + $1.pottingPercentage }) / results.count
    }

    var failableCompletedCount: Int {
        guard drill.isFailable else { return 0 }

        return results.filter { $0.missCount == 0 }.count
    }

    var failableCompletionPercentage: Int {
        guard drill.isFailable else { return 0 }
        guard results.count > 0 else { return 0 }

        return failableCompletedCount * 100 / results.count
    }

    var chartDataPoints: [CGFloat] {
        guard drill.attempts > 0 else { return [] }

        var dataPoints = results.map { CGFloat($0.potCount) / CGFloat(drill.attempts) }

        if dataPoints.count > 100 {
            dataPoints = dataPoints[0..<100].map { $0 }
        }

        // Reverse latest points to the end of array.
        return dataPoints.reversed()
    }
}
