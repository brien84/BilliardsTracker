//
//  RunningView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct RunningView: View {
    @ObservedObject private var statistics: StatisticsManager

    init(drill: Drill, startDate: Date) {
        self.statistics = StatisticsManager(drill: drill, afterDate: startDate)
    }

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: .zero) {
                StatisticsPanel(statistics: statistics)

                CardView {
                    ResultsView(results: statistics.results)
                }
                .setTitle("Results")
            }
        }
        .navigationBarTitle(statistics.drill.title)
    }
}

struct RunningView_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var drill = store.loadDrills().first!

    static var view: some View {
        NavigationView {
            RunningView(drill: drill, startDate: Date(timeIntervalSince1970: 0))
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
