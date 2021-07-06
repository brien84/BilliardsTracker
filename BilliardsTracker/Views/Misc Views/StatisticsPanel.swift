//
//  StatisticsPanel.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-03.
//

import SwiftUI

struct StatisticsPanel: View {
    private let statistics: StatisticsManager

    init(statistics: StatisticsManager) {
        self.statistics = statistics
    }

    var body: some View {
        VStack(spacing: .zero) {
            headerView
                .padding()

            HStack {
                if statistics.drill.isFailable {
                    StatisticLabel(title: "Completed", value: "\(statistics.failableCompletedCount)")
                        .titleColor(.customGreen)

                    StatisticLabel(title: "Completion", value: "\(statistics.failableCompletionPercentage)%")
                        .titleColor(statistics.failableCompletionPercentage > 50 ? .customGreen : .customRed)

                    StatisticLabel(title: "Average Pots", value: "\(statistics.averagePots)")
                        .titleColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)
                } else {
                    StatisticLabel(title: "Pots", value: "\(statistics.potCount)")
                        .titleColor(.customGreen)

                    StatisticLabel(title: "Potting", value: "\(statistics.pottingPercentage)%")
                        .titleColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)

                    StatisticLabel(title: "Misses", value: "\(statistics.missCount)")
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

            if statistics.attemptsCount == 1 {
                Text("1 shot")
            } else {
                Text("\(statistics.attemptsCount) shots")
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

private extension CGFloat {
    static var labelVerticalSpacing: CGFloat {
        8
    }
}

struct StatisticsPanel_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var drill = store.loadDrills().first { !$0.isFailable }!

    static var view: some View {
        ZStack {
            Color.primaryBackground

            StatisticsPanel(statistics: StatisticsManager(drill: drill))
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}

struct StatisticsPanelFailableDrill_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var drill = store.loadDrills().first { $0.isFailable }!

    static var view: some View {
        ZStack {
            Color.primaryBackground

            StatisticsPanel(statistics: StatisticsManager(drill: drill))
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
