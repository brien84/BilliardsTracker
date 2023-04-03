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

    @State private var isShowingHistory = false
    @State private var isShowingDeleteAlert = false

    private var infoMessage: String? {
        guard !isShowingHistory else { return nil }
        return "Only latest 100 results are shown."
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            let isDataSufficient = viewStore.statistics.results.count > 2

            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: .zero) {
                    StatisticsPanel(statistics: viewStore.statistics)

                    CardView(
                        title: isShowingHistory ? "History" : "Performance",
                        infoMessage: viewStore.statistics.results.count > 100 ? infoMessage : nil
                    ) {
                        if isDataSufficient {
                            if isShowingHistory {
                                ResultsView(results: viewStore.statistics.results)
                            } else {
                                ChartView(
                                    dataPoints: viewStore.statistics.chartDataPoints,
                                    maxValue: viewStore.drill.shotCount
                                )
                                .padding()
                            }
                        } else {
                            IllustratedTextView(
                                imageName: "pocket",
                                text: "Not enough data"
                            )
                            .offset(Self.textViewOffset)
                        }
                    }
                    .id(isShowingHistory)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: isShowingHistory ? .trailing : .leading),
                            removal: .move(edge: isShowingHistory ? .leading : .trailing)
                        )
                    )
                }
            }
            .alert(isPresented: $isShowingDeleteAlert) {
                Alert(
                    title: Text("Confirmation"),
                    message: Text("Are you sure you want to delete this drill?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewStore.send(.didTapDeleteButton)
                    },
                    secondaryButton: .cancel()
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    deleteButton
                        .frame(width: Self.toolbarItemWidth)

                    toggleViewButton
                        .foregroundColor(isDataSufficient ? .primaryElement : .secondaryElement)
                        .disabled(!isDataSufficient)
                        .frame(width: Self.toolbarItemWidth)
                        .animation(.none, value: isShowingHistory)
                }
            }
            .navigationTitle(viewStore.drill.title)
        }
    }

    private var deleteButton: some View {
        Button {
            isShowingDeleteAlert = true
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

// MARK: - Constants

private extension StatisticsView {
    static let toolbarItemWidth: CGFloat = 32
    static let textViewOffset: CGSize = CGSize(width: 0, height: -24)
}

// MARK: - Previews

struct StatisticsView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Statistics.State(
            drill: PersistenceClient.mockDrill
        ),
        reducer: Statistics()
    )

    static var previews: some View {
        NavigationView {
            StatisticsView(store: store)
        }
    }
}

struct StatisticsViewNotEnoughData_Previews: PreviewProvider {
    static let drill = {
        let drill = PersistenceClient.mockDrill
        let results = drill.results
        results.forEach { drill.removeFromResultsValue($0) }
        return drill
    }()

    static let store = Store(
        initialState: Statistics.State(drill: drill),
        reducer: Statistics()
    )

    static var previews: some View {
        NavigationView {
            StatisticsView(store: store)
        }
    }
}
