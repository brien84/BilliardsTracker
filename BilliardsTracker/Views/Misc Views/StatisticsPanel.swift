//
//  StatisticsPanel.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-03.
//

import SwiftUI

struct StatisticsPanel: View {
    let statistics: StatisticsManager

    var body: some View {
        VStack(spacing: .zero) {
            headerView
                .padding()

            HStack {
                if statistics.drill.isFailable {
                    StatisticLabel(title: "Completed", value: "\(statistics.completionCount)")
                        .titleColor(.customGreen)

                    StatisticLabel(title: "Completion", value: "\(statistics.completionPercentage)%")
                        .titleColor(statistics.completionPercentage > 50 ? .customGreen : .customRed)

                    StatisticLabel(title: "Average Pots", value: "\(statistics.averagePots)")
                        .titleColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)
                } else {
                    StatisticLabel(title: "Pots", value: "\(statistics.totalPotCount)")
                        .titleColor(.customGreen)

                    StatisticLabel(title: "Potting", value: "\(statistics.pottingPercentage)%")
                        .titleColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)

                    StatisticLabel(title: "Misses", value: "\(statistics.totalMissCount)")
                        .titleColor(.customRed)
                }
            }
            .padding()
        }
    }

    private var headerView: some View {
        HStack {
            if statistics.results.count == 1 {
                Text("1 attempt")
            } else {
                Text("\(statistics.results.count) attempts")
            }

            Spacer()

            if statistics.totalAttemptsCount == 1 {
                Text("1 shot")
            } else {
                Text("\(statistics.totalAttemptsCount) shots")
            }
        }
        .frame(maxWidth: .infinity)
        .font(Font.subheadline.weight(.light))
        .foregroundColor(.primaryElement)
    }
}

private struct StatisticLabel: View {
    private var title: String
    private var value: String

    @State private var titleColor = Color.secondaryElement

    var body: some View {
        VStack(spacing: .labelVerticalSpacing) {
            Text(value)
                .font(.title2)
                .foregroundColor(titleColor)
            Text(title)
                .font(Font.subheadline.weight(.light))
                .foregroundColor(.secondaryElement)
        }
        .frame(maxWidth: .infinity)
    }

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    func titleColor(_ color: Color) -> some View {
        var view = self
        view._titleColor = State(initialValue: color)
        return view.id(UUID())
    }
}

// MARK: - Constants

private extension CGFloat {
    static var labelVerticalSpacing: CGFloat {
        8
    }
}

// MARK: - Previews

struct StatisticsPanel_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsPanel(statistics: StatisticsManager(drill: PersistenceClient.previewData.first!))
    }
}
