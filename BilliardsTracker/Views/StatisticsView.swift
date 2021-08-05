//
//  StatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: StoreManager

    private let statistics: StatisticsManager

    @State private var showHistory = false
    @State private var showDeleteAlert = false
    @State private var shouldDelete = false

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
                            noDataLabel
                        } else {
                            ResultsView(results: statistics.results)
                                .accessibility(identifier: "statisticsView_resultsView")
                        }
                    } else {
                        if statistics.results.count < 2 {
                            noDataLabel
                        } else {
                            ChartView(dataPoints: statistics.chartDataPoints, maxValue: statistics.drill.attempts)
                                .padding()
                                .accessibility(identifier: "statisticsView_chartView")
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
        .onDisappear {
            if shouldDelete {
                withAnimation {
                    store.delete(drill: statistics.drill)
                }
            }
        }
        .navigationBarTitle(statistics.drill.title)
        .navigationBarItems(trailing: HStack(alignment: .firstTextBaseline, spacing: .navigationBarItemWidth) {
            deleteButton.frame(width: .navigationBarItemWidth)
            toggleHistoryButton.frame(width: .navigationBarItemWidth)
        })
    }

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
        .disabled(statistics.results.isEmpty)
        .foregroundColor(statistics.results.isEmpty ? .secondaryElement : .primaryElement)
        .accessibility(identifier: "statisticsView_toggleHistoryButton")
    }

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
                    shouldDelete = true
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        })
        .accessibility(identifier: "statisticsView_deleteButton")
    }

    private var noDataLabel: some View {
        VStack(spacing: .noDataLabelSpacing) {
            Image("pocket")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: .noDataLabelWidth, height: .noDataLabelHeight)

            Text("Not enough data")
                .font(.title3)
                .foregroundColor(.primaryElement)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(.noDataLabelOffset)
        .accessibility(identifier: "statisticsView_noDataLabel")
    }
}

private extension CGFloat {
    static var navigationBarItemWidth: CGFloat {
        30
    }

    static var noDataLabelSpacing: CGFloat {
        16
    }

    static var noDataLabelWidth: CGFloat {
        100
    }

    static var noDataLabelHeight: CGFloat {
        100
    }
}

private extension CGSize {
    static var noDataLabelOffset: CGSize {
        CGSize(width: 0, height: -32)
    }
}

// swiftlint:disable force_try
struct StatisticsView_Previews: PreviewProvider {
    static var store = StoreManager(store: try! DrillStore(inMemory: true, isPreview: true))
    static var drill = store.drills.first!

    static var view: some View {
        NavigationView {
            NavigationLink(
                destination: StatisticsView(drill: drill).environmentObject(store),
                isActive: .constant(true),
                label: { Text("Preview") }
            )
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}

struct StatisticsViewNotEnoughData_Previews: PreviewProvider {
    static var drillStore = try! DrillStore(inMemory: true, isPreview: false)

    static var drill: Drill = {
        drillStore.createDrill(title: "EmptyDrill", attempts: 10, isFailable: false)
        return store.drills.first!
    }()

    static var store = StoreManager(store: drillStore)

    static var view: some View {
        NavigationView {
            NavigationLink(
                destination: StatisticsView(drill: drill).environmentObject(store),
                isActive: .constant(true),
                label: { Text("Preview") }
            )
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
