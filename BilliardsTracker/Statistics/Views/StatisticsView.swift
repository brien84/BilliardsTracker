//
//  StatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-14.
//

import SwiftUI

struct StatisticsView: View {
    let mode: StatisticsView.Mode
    let statistics: Statistics

    enum Mode {
        case compact
        case full
    }

    var body: some View {
        if mode == .compact {
            CompactView(statistics: statistics)
        } else {
            FullView(statistics: statistics)
        }
    }
}

private struct CompactView: View {
    let statistics: Statistics

    var body: some View {
        if statistics.drill.isContinuous {
            HStack {
                StatisticsLabel(title: "Potted", value: statistics.potCount, mode: .compact)
                    .foregroundColor(.customGreen)

                StatisticsLabel(title: "Potted %", value: statistics.potPercentage, isPercentage: true, mode: .compact)
                    .foregroundColor(.getColorFor(percentage: statistics.potPercentage))

                StatisticsLabel(title: "Missed", value: statistics.missCount, mode: .compact)
                    .foregroundColor(.customRed)
            }
            .padding()
        } else {
            HStack {
                StatisticsLabel(title: "Completed", value: statistics.completionCount, mode: .compact)
                    .foregroundColor(.customGreen)

                StatisticsLabel(title: "Completion", value: statistics.completionPercentage, isPercentage: true, mode: .compact)
                    .foregroundColor(.getColorFor(percentage: statistics.completionPercentage))

                StatisticsLabel(title: "Avg. Potted", value: statistics.potAverage, mode: .compact)
                    .foregroundColor(.customGreen)
            }
            .padding()
        }
    }
}

private struct FullView: View {
    let statistics: Statistics

    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            HStack {
                StatisticsLabel(title: "Attempts", value: statistics.attemptsCount)
                    .foregroundColor(.primaryElement)

                StatisticsLabel(title: "Total Shots", value: statistics.shotCount)
                    .foregroundColor(.primaryElement)
            }

            Divider()

            HStack {
                StatisticsLabel(title: "Shots Potted", value: statistics.potCount)
                    .foregroundColor(.customGreen)

                StatisticsLabel(title: "Shots Missed", value: statistics.missCount)
                    .foregroundColor(.customRed)
            }

            Divider()

            HStack {
                StatisticsLabel(title: "Average Potted", value: statistics.potAverage)
                    .foregroundColor(.customGreen)

                StatisticsLabel(title: "Average Missed", value: statistics.missAverage)
                    .foregroundColor(.customRed)
            }

            Divider()

            HStack {
                StatisticsLabel(title: "Potted %", value: statistics.potPercentage, isPercentage: true)
                    .foregroundColor(.customGreen)

                StatisticsLabel(title: "Missed %", value: statistics.missPercentage, isPercentage: true)
                    .foregroundColor(.customRed)
            }

            if !statistics.drill.isContinuous {
                Divider()

                HStack {
                    StatisticsLabel(title: "Completed", value: statistics.completionCount)
                        .foregroundColor(.customGreen)

                    StatisticsLabel(title: "Completion %", value: statistics.completionPercentage, isPercentage: true)
                        .foregroundColor(.getColorFor(percentage: statistics.completionPercentage))
                }
            }
        }
        .padding()
    }
}

private struct StatisticsLabel: View {
    let title: String
    let value: String
    let mode: StatisticsView.Mode

    init(title: String, value: Int, mode: StatisticsView.Mode = .full) {
        self.title = title
        self.value = String(value)
        self.mode = mode
    }

    init(title: String, value: Double, isPercentage: Bool = false, mode: StatisticsView.Mode = .full) {
        self.title = title
        self.mode = mode

        if floor(value) == value {
            self.value = String(format: "%.0f", value) + (isPercentage ? "%" : "")
        } else {
            self.value = String(format: "%.1f", value) + (isPercentage ? "%" : "")
        }
    }

    var body: some View {
        if mode == .compact {
            VStack(spacing: Self.verticalSpacing) {
                Text(value)
                    .font(.title3.weight(.medium))

                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.secondaryElement)
            }
            .frame(maxWidth: .infinity)
        }

        if mode == .full {
            VStack(spacing: Self.verticalSpacing) {
                Text(title)
                    .font(.body.bold())
                    .foregroundColor(.secondaryElement)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(value)
                    .font(.title3.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Constants

private extension Color {
    static func getColorFor(percentage: Double) -> Color {
        if percentage == 50 {
            return .primaryElement
        }

        if percentage > 50 {
            return .customGreen
        } else {
            return .customRed
        }
    }
}

private extension FullView {
    static let verticalSpacing: CGFloat = 8
}

private extension StatisticsLabel {
    static let verticalSpacing: CGFloat = 4
}

// MARK: - Previews

struct CompactStatisticsView_Previews: PreviewProvider {
    static let statistics = Statistics(drill: PersistenceClient.mockDrill)

    static var previews: some View {
        StatisticsView(mode: .compact, statistics: statistics)
    }
}

struct FullStatisticsView_Previews: PreviewProvider {
    static let statistics = Statistics(drill: PersistenceClient.mockDrill)

    static var previews: some View {
        StatisticsView(mode: .full, statistics: statistics)
    }
}
