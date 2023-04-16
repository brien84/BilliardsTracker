//
//  StatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-14.
//

import SwiftUI

struct StatisticsView: View {
    let statistics: Statistics

    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            HStack {
                if statistics.results.count == 1 {
                    Text("1 attempt")
                } else {
                    Text("\(statistics.results.count) attempts")
                }

                Spacer()

                if statistics.shotCount == 1 {
                    Text("1 shot")
                } else {
                    Text("\(statistics.shotCount) shots")
                }
            }
            .font(.subheadline.weight(.light))
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity)

            HStack {
                if statistics.drill.isContinuous {
                    StatisticsLabel(title: "Pots", value: "\(statistics.potCount)")
                        .foregroundColor(.customGreen)

                    StatisticsLabel(title: "Potting", value: "\(statistics.potPercentage)%")
                        .foregroundColor(statistics.potPercentage > 50 ? .customGreen : .customRed)

                    StatisticsLabel(title: "Misses", value: "\(statistics.missCount)")
                        .foregroundColor(.customRed)
                } else {
                    StatisticsLabel(title: "Completed", value: "\(statistics.completionCount)")
                        .foregroundColor(.customGreen)

                    StatisticsLabel(title: "Completion", value: "\(statistics.completionPercentage)%")
                        .foregroundColor(statistics.completionPercentage > 50 ? .customGreen : .customRed)

                    StatisticsLabel(title: "Average Pots", value: "\(statistics.potAverage)")
                        .foregroundColor(statistics.potPercentage > 50 ? .customGreen : .customRed)
                }
            }
        }
        .padding()
    }
}

private struct StatisticsLabel: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            Text(value)
                .font(.title2.weight(.medium))

            Text(title)
                .font(.subheadline.weight(.light))
                .foregroundColor(.primaryElement)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Constants

private extension StatisticsLabel {
    static let verticalSpacing: CGFloat = 8
}

private extension StatisticsView {
    static let verticalSpacing: CGFloat = 32
}
