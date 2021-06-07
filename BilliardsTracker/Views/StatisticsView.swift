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
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: .zero) {
                StatisticsPanel(statistics: statistics)

                CardView {
                    if showHistory {
                        ResultsView(results: statistics.results)
                    } else {
                        ChartView(dataPoints: statistics.chartDataPoints, maxValue: statistics.drill.attempts)
                            .padding()
                    }
                }
                .setTitle(showHistory ? "History" : "Performance")
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

struct StatisticsViewNotEnoughData_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: false)
    static var manager = DrillManager(store: store)

    static var drill: Drill = {
        store.createDrill(title: "EmptyDrill", attempts: 10, isFailable: false)
        return manager.drills.first!
    }()

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
