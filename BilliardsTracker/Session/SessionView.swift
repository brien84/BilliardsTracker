//
//  SessionView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct SessionView: View {
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
                        waitingForResultsLabel
                            .offset(.waitingForResultsLabelOffset)
                    } else {
                        ResultsView(results: statistics.results)
                    }
                }
                .setTitle("Results")
            }
        }
        .animation(.easeInOut)
        .navigationBarTitle(statistics.drill.title)
    }

    private var waitingForResultsLabel: some View {
        VStack(spacing: .waitingForResultsLabelSpacing) {
            Image("table")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: .waitingForResultsLabelWidth,
                       height: .waitingForResultsLabelHeight)

            Text("Waiting for results...")
                .font(.title3)
                .foregroundColor(.primaryElement)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension CGFloat {
    static var waitingForResultsLabelSpacing: CGFloat {
        16
    }

    static var waitingForResultsLabelWidth: CGFloat {
        100
    }

    static var waitingForResultsLabelHeight: CGFloat {
        100
    }
}

private extension CGSize {
    static var waitingForResultsLabelOffset: CGSize {
        CGSize(width: 0, height: -32)
    }
}

// swiftlint:disable force_try
struct SessionView_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var drill = store.loadDrills().first!

    static var view: some View {
        NavigationView {
            SessionView(drill: drill, startDate: Date(timeIntervalSince1970: 0))
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}

struct SessionViewWaiting_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var drill = store.loadDrills().first!

    static var view: some View {
        NavigationView {
            SessionView(drill: drill, startDate: Date(timeIntervalSinceNow: 10000))
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
