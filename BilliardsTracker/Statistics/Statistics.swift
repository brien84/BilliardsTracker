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

    var attemptsCount: Int {
        results.count
    }

    var shotCount: Int {
        results.reduce(0, { $0 + $1.potCount + $1.missCount })
    }

    var potCount: Int {
        results.reduce(0, { $0 + $1.potCount })
    }

    var missCount: Int {
        results.reduce(0, { $0 + $1.missCount })
    }

    var potAverage: Float {
        guard results.count > 0 else { return 0 }
        return Float(potCount) / Float(results.count)
    }

    var missAverage: Float {
        guard results.count > 0 else { return 0 }
        return Float(missCount) / Float(results.count)
    }

    var potPercentage: Float {
        guard results.count > 0 else { return 0 }
        return results.reduce(0, { $0 + $1.potPercentage }) / Float(results.count)
    }

    var highestPotPercentage: Float {
        let result = results.max { $0.potPercentage < $1.potPercentage }
        return result?.potPercentage ?? 0
    }

    var lowestPotPercentage: Float {
        let result = results.max { $0.potPercentage > $1.potPercentage }
        return result?.potPercentage ?? 0
    }

    var missPercentage: Float {
        guard results.count > 0 else { return 0 }
        return results.reduce(0, { $0 + $1.missPercentage }) / Float(results.count)
    }

    var completionCount: Int {
        results.filter { $0.missCount == 0 }.count
    }

    var completionPercentage: Float {
        guard results.count > 0 else { return 0 }
        return Float(completionCount * 100) / Float(results.count)
    }

    var chartDataPoints: [CGFloat] {
        guard drill.shotCount > 0 else { return [] }

        var dataPoints = results.map { CGFloat($0.potCount) / CGFloat(drill.shotCount) }

        if dataPoints.count > 100 {
            dataPoints = dataPoints[0..<100].map { $0 }
        }

        // Reverses the order of the array, placing
        // the latest data points at the front of the array.
        return dataPoints.reversed()
    }
}

extension Statistics: Equatable {
    static func == (lhs: Statistics, rhs: Statistics) -> Bool {
        lhs.results == rhs.results
    }
}

private extension DrillResult {
    var potPercentage: Float {
        guard let drill = drill else { return 0 }
        return Float(potCount) / Float(drill.shotCount) * 100
    }

    var missPercentage: Float {
        guard let drill = drill else { return 0 }
        return Float(missCount) / Float(drill.shotCount) * 100
    }
}
