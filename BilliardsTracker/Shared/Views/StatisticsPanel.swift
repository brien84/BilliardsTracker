//
//  StatisticsPanel.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-03.
//

import SwiftUI

struct StatisticsPanel: View {
    let statistics: StatisticsClient

    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            HStack {
                if statistics.results.count == 1 {
                    Text("1 attempt")
                } else {
                    Text("\(statistics.results.count) attempts")
                }

                Spacer()

                if statistics.totalShotCount == 1 {
                    Text("1 shot")
                } else {
                    Text("\(statistics.totalShotCount) shots")
                }
            }
            .font(.subheadline.weight(.light))
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity)

            HStack {
                if statistics.drill.isContinuous {
                    StatisticsLabel(title: "Pots", value: "\(statistics.totalPotCount)")
                        .foregroundColor(.customGreen)

                    StatisticsLabel(title: "Potting", value: "\(statistics.pottingPercentage)%")
                        .foregroundColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)

                    StatisticsLabel(title: "Misses", value: "\(statistics.totalMissCount)")
                        .foregroundColor(.customRed)
                } else {
                    StatisticsLabel(title: "Completed", value: "\(statistics.completionCount)")
                        .foregroundColor(.customGreen)

                    StatisticsLabel(title: "Completion", value: "\(statistics.completionPercentage)%")
                        .foregroundColor(statistics.completionPercentage > 50 ? .customGreen : .customRed)

                    StatisticsLabel(title: "Average Pots", value: "\(statistics.averagePots)")
                        .foregroundColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)
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

private extension StatisticsPanel {
    static let verticalSpacing: CGFloat = 32
}

// MARK: - Previews

struct StatisticsPanel_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsPanel(statistics: StatisticsClient(drill: PersistenceClient.mockDrill))
    }
}
