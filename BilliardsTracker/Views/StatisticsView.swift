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
                        if statistics.results.count < 1 {
                            notEnoughDataMessage
                        } else {
                            ResultsView(results: statistics.results)
                        }
                    } else {
                        if statistics.results.count < 2 {
                            notEnoughDataMessage
                        } else {
                            ChartView(dataPoints: statistics.chartDataPoints, maxValue: statistics.drill.attempts)
                                .padding()
                        }
                    }
                }
                .setTitle(showHistory ? "History" : "Performance")
                .setInfo(showHistory ? nil : statistics.results.count > 100 ? "Only latest 100 results are shown" : nil)
                .id(UUID())

                .transition(.asymmetric(insertion: .move(edge: showHistory ? .trailing : .leading),
                                        removal: .move(edge: showHistory ? .leading : .trailing)))
            }
        }
        .navigationBarTitle(statistics.drill.title)
        .navigationBarItems(trailing: HStack(alignment: .firstTextBaseline, spacing: .navigationBarItemWidth) {
            deleteButton.frame(width: .navigationBarItemWidth)
            toggleHistoryButton.frame(width: .navigationBarItemWidth)
        })
    }

    @State private var showHistory = false

    private var toggleHistoryButton: some View {
        Button {
            withAnimation {
                showHistory.toggle()
            }
        } label: {
            Image(systemName: showHistory ? "chart.bar.xaxis" : "tray.full")
                .font(Font.body)
                .imageScale(.large)
        }
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
                    withAnimation {
                        manager.delete(drill: statistics.drill)
                    }
                },
                secondaryButton: .cancel()
            )
        })
    }

    private var notEnoughDataMessage: some View {
        VStack {
            Text("Not enough data")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .font(Font.title3.weight(.semibold))
        .foregroundColor(.primaryElement)
    }
}

private extension CGFloat {
    static var navigationBarItemWidth: CGFloat {
        30
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
