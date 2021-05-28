//
//  StatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: DrillManager
    private let statistics: StatisticsManager

    init(drill: Drill) {
        self.statistics = StatisticsManager(drill: drill)
    }

    var body: some View {
        VStack(spacing: 0) {
            StatisticsPanel(statistics: statistics)

            Text(showHistory ? "History" : "Last results")
                .font(.title)
                .bold()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            if showHistory {
                HistoryView(results: statistics.results)
            } else {
                ChartView(dataPoints: statistics.chartDataPoints, maxValue: statistics.drill.attempts)
                    .padding()
                    .background(Color.yellow)
            }
        }
        .navigationBarTitle(statistics.drill.title)
        .navigationBarItems(trailing: HStack(alignment: .firstTextBaseline, spacing: 30) {
                                deleteButton; toggleHistoryButton })
    }

    @State private var showDeleteAlert = false

    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
                .font(Font.body)
                .imageScale(.large)
                .foregroundColor(.customRed)
        }
        .alert(isPresented: $showDeleteAlert, content: {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to delete this drill?"),
                primaryButton: .destructive(Text("Delete")) {
                    manager.delete(drill: statistics.drill)
                },
                secondaryButton: .cancel()
            )
        })
    }

    @State private var showHistory = false

    private var toggleHistoryButton: some View {
        Button {
            showHistory.toggle()
        } label: {
            Image(systemName: showHistory ? "chart.bar.xaxis" : "tray.full")
                .font(Font.body)
                .imageScale(.large)
        }
    }
}

private struct HistoryView: View {
    private let results: [DrillResult]

    init(results: [DrillResult]) {
        self.results = results
    }

    var body: some View {
        ScrollView {
            ForEach(results) { result in
                ResultView(result: result)
            }
        }
    }
}

private struct StatisticsPanel: View {
    private let statistics: StatisticsManager

    init(statistics: StatisticsManager) {
        self.statistics = statistics
    }

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Text("\(statistics.results.count) sessions")
                    .font(.callout)
                    .fontWeight(.light)
                Spacer()
                Text("\(statistics.totalAttempts) attempts")
                    .font(.callout)
                    .fontWeight(.light)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.red)

            HStack(spacing: 0) {
                VStack {
                    Text("\(statistics.totalPotCount)")
                        .font(.title2)
                    Text("Pots")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("\(statistics.totalMissCount)")
                        .font(.title2)
                    Text("Misses")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("\(statistics.totalPottingPercentage)%")
                        .font(.title2)
                    Text("Average")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.blue)
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))
    static var drill = manager.drills.first!

    static var view: some View {
        NavigationView {
            StatisticsView(drill: drill)
                .environmentObject(manager)
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
