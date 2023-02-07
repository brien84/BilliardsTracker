//
//  StatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import ComposableArchitecture
import SwiftUI

struct StatisticsView: View {
    let store: StoreOf<Statistics>

    @Environment(\.presentationMode) var presentationMode

    private let statistics: StatisticsManager

    @State private var isShowingHistory = false
    @State private var showDeleteAlert = false

    init(store: StoreOf<Statistics>) {
        self.store = store
        let drill = ViewStore(store).drill
        self.statistics = StatisticsManager(drill: drill)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: .zero) {
                    StatisticsPanel(statistics: statistics)

                    CardView {
                        if isShowingHistory {
                            if statistics.results.count < 1 {
                                NotEnoughDataLabel()
                            } else {
                                ResultsView(results: statistics.results)
                                    .accessibility(identifier: "statisticsView_resultsView")
                            }
                        } else {
                            if statistics.results.count < 2 {
                                NotEnoughDataLabel()
                            } else {
                                ChartView(dataPoints: statistics.chartDataPoints, maxValue: statistics.drill.attempts)
                                    .padding()
                                    .accessibility(identifier: "statisticsView_chartView")
                            }
                        }
                    }
                    .setTitle(isShowingHistory ? "History" : "Performance")
                    .setInfo(isShowingHistory ? nil : statistics.results.count > 100 ? "Only latest 100 results are shown" : nil)
                    .id(UUID())
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: isShowingHistory ? .trailing : .leading),
                            removal: .move(edge: isShowingHistory ? .leading : .trailing)
                        )
                    )
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Confirmation"),
                    message: Text("Are you sure you want to delete this drill?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewStore.send(.didTapDeleteButton)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .toolbar {
                ToolbarItemGroup {
                    deleteButton
                        .frame(width: Self.toolbarItemWidth)

                    toggleViewButton
                        .foregroundColor(statistics.results.isEmpty ? .secondaryElement : .primaryElement)
                        .disabled(statistics.results.isEmpty)
                        .frame(width: Self.toolbarItemWidth)
                }
            }
            .navigationTitle(statistics.drill.title)
        }
    }

    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
                .font(.body)
                .imageScale(.large)
                .foregroundColor(.customRed)
        }
    }

    private var toggleViewButton: some View {
        Button {
            withAnimation {
                isShowingHistory.toggle()
            }
        } label: {
            Image(systemName: isShowingHistory ? "chart.bar.xaxis" : "tray.full")
                .font(.body)
                .imageScale(.large)
        }
    }
}

private struct NotEnoughDataLabel: View {
    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            Image("pocket")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Self.width, height: Self.height)

            Text("Not enough data")
                .font(.title3)
                .foregroundColor(.primaryElement)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(Self.offset)
    }
}

// MARK: - Constants

private extension StatisticsView {
    static let toolbarItemWidth: CGFloat = 32
}

private extension NotEnoughDataLabel {
    static let verticalSpacing: CGFloat = 16
    static let height: CGFloat = 100
    static let width: CGFloat = 100
    static let offset: CGSize = CGSize(width: 0, height: -32)
}

// MARK: - Previews

struct StatisticsView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Statistics.State(drill: PersistenceClient.previewData.first!),
        reducer: Statistics()
    )

    static var previews: some View {
        StatisticsView(store: store)
    }
}
