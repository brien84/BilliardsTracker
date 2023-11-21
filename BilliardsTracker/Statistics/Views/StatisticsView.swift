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
                StatisticsLabel(
                    title: "Attempts",
                    value: statistics.attemptsCount
                )

                StatisticsLabel(
                    title: "Total Shots",
                    value: statistics.shotCount
                )
            }

            Divider()

            HStack {
                StatisticsLabel(
                    title: "Shots Potted",
                    value: statistics.potCount
                ).color(.customGreen)

                StatisticsLabel(
                    title: "Shots Missed",
                    value: statistics.missCount
                ).color(.customRed)
            }

            Divider()

            HStack {
                StatisticsLabel(
                    title: "Average Potted",
                    value: statistics.potAverage
                ).color(.customGreen)

                StatisticsLabel(
                    title: "Potted %",
                    value: statistics.potPercentage,
                    isPercentage: true
                )
            }

            Divider()

            HStack {
                if statistics.drill.isContinuous {
                    StatisticsLabel(
                        title: "Highest Potted %",
                        value: statistics.highestPotPercentage,
                        isPercentage: true
                    )

                    StatisticsLabel(
                        title: "Lowest Potted %",
                        value: statistics.lowestPotPercentage,
                        isPercentage: true
                    )
                } else {
                    StatisticsLabel(
                        title: "Completed",
                        value: statistics.completionCount
                    ).color(.customGreen)

                    StatisticsLabel(
                        title: "Completion %",
                        value: statistics.completionPercentage,
                        isPercentage: true
                    )
                }
            }
        }
        .padding()
    }
}

private struct StatisticsLabel: View {
    let title: String
    let value: String
    var color: Color = .primaryElement

    init(title: String, value: Int) {
        self.title = title
        self.value = String(value)
    }

    init(title: String, value: Float, isPercentage: Bool = false) {
        self.title = title

        if floor(value) == value {
            self.value = String(format: "%.0f", value) + (isPercentage ? "%" : "")
        } else {
            self.value = String(format: "%.1f", value) + (isPercentage ? "%" : "")
        }

        if isPercentage {
            if value > 50 { self.color = .customGreen }
            if value < 50 { self.color = .customRed }
        }
    }

    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            Text(title)
                .font(.body.bold())
                .foregroundStyle(Color.secondaryElement)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(.title3.weight(.medium))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension StatisticsLabel {
    func color(_ color: Color) -> StatisticsLabel {
        var copy = self
        copy.color = color
        return copy
    }
}

// MARK: - Constants

private extension StatisticsView {
    static let verticalSpacing: CGFloat = 8
}

private extension StatisticsLabel {
    static let verticalSpacing: CGFloat = 4
}

// MARK: - Previews

#Preview {
    let statistics = Statistics(drill: PersistenceClient.mockDrill)

    return ZStack {
        Color.primaryBackground
            .ignoresSafeArea()

        StatisticsView(statistics: statistics)
            .roundedBackground()
    }
}
