//
//  Statistics.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-22.
//

import SwiftUI

struct Statistics {
    let drill: Drill
    let results: [DrillResult]

    init(drill: Drill, startDate: Date? = nil) {
        self.drill = drill

        if let startDate {
            self.results = drill.results.filter { $0.date > startDate }
        } else {
            self.results = drill.results
        }
    }

    var totalShotCount: Int {
        results.reduce(0, { $0 + $1.potCount + $1.missCount })
    }

    var totalPotCount: Int {
        results.reduce(0, { $0 + $1.potCount })
    }

    var totalMissCount: Int {
        results.reduce(0, { $0 + $1.missCount })
    }

    var averagePots: Double {
        guard results.count > 0 else { return 0 }

        let result = Double(totalPotCount) / Double(results.count)

        return floor(result * 10) / 10.0
    }

    var pottingPercentage: Int {
        guard results.count > 0 else { return 0 }

        return results.reduce(0, { $0 + $1.pottingPercentage }) / results.count
    }

    var completionCount: Int {
        results.filter { $0.missCount == 0 }.count
    }

    var completionPercentage: Int {
        guard results.count > 0 else { return 0 }

        return completionCount * 100 / results.count
    }

    var chartDataPoints: [CGFloat] {
        guard drill.shotCount > 0 else { return [] }

        var dataPoints = results.map { CGFloat($0.potCount) / CGFloat(drill.shotCount) }

        if dataPoints.count > 100 {
            dataPoints = dataPoints[0..<100].map { $0 }
        }

        // Reverse latest points to the end of array.
        return dataPoints.reversed()
    }
}

extension Statistics: Equatable {
    static func == (lhs: Statistics, rhs: Statistics) -> Bool {
        lhs.results == rhs.results
    }
}

extension DrillResult {
    var pottingPercentage: Int {
        guard let drill = drill else { return 0 }

        return Int(Double(potCount) / Double(drill.shotCount) * 100)
    }
}
