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
                    if statistics.results.isEmpty {
                        waitingMessage
                    } else {
                        ResultsView(results: statistics.results)
                    }
                }
                .setTitle("Results")
            }
        }
        .navigationBarTitle(statistics.drill.title)
    }

    private var waitingMessage: some View {
        VStack {
            Text("Waiting for results...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .font(Font.title3.weight(.semibold))
        .foregroundColor(.primaryElement)
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

struct RunningViewWaiting_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var drill = store.loadDrills().first!

    static var view: some View {
        NavigationView {
            RunningView(drill: drill, startDate: Date(timeIntervalSinceNow: 10000))
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
