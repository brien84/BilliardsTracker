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
                        WaitingLabelView()
                            .offset(Self.waitingLabelOffset)
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
}

private struct WaitingLabelView: View {
    var body: some View {
        VStack(spacing: Self.spacing) {
            Image("table")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Self.width, height: Self.height)

            Text("Waiting for results...")
                .font(.title3)
                .foregroundColor(.primaryElement)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension SessionView {
    static let waitingLabelOffset: CGSize = CGSize(width: 0, height: -32)
}

private extension WaitingLabelView {
    static let spacing: CGFloat = 16
    static let width: CGFloat = 100
    static let height: CGFloat = 100
}

// MARK: - Previews

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
