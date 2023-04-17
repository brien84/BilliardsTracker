//
//  DrillLogView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import ComposableArchitecture
import SwiftUI

struct DrillLogView: View {
    let store: StoreOf<DrillLog>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if viewStore.statistics.results.count > Self.minimumResultCount {
                    ScrollView {
                        VStack(spacing: .zero) {
                            SectionLabelView(title: "Statistics")

                            StatisticsView(mode: .full, statistics: viewStore.statistics)
                                .roundedBackground()

                            SectionLabelView(title: "Performance")

                            ChartView(
                                dataPoints: viewStore.statistics.chartDataPoints,
                                maxValue: viewStore.drill.shotCount
                            )
                            .frame(maxWidth: .infinity)
                            .aspectRatio(Self.chartAspectRatio, contentMode: .fit)
                            .padding()
                            .padding(.top)
                            .roundedBackground()

                            HStack(alignment: .bottom) {
                                SectionLabelView(title: "History")

                                Button("Show More") {
                                    viewStore.send(.didPressShowFullHistoryButton)
                                }
                                .foregroundColor(.customBlue)
                                .padding(.horizontal)
                                .padding(.bottom, Self.showFullHistoryButtonBottomPadding)
                            }

                            ResultListView(results: Array(viewStore.statistics.results.prefix(5)))
                                .roundedBackground()
                                .padding(.bottom)
                        }
                    }
                } else {
                    IllustratedTextView(
                        imageName: "pocket",
                        text: "Not enough data"
                    )
                }
            }
            .background(Color.primaryBackground)
            .navigationTitle(viewStore.drill.title)
            .alert(
                store.scope(state: \.alert),
                dismiss: .alertDidDismiss
            )
            .sheet(isPresented: viewStore.binding(\.$isNavigationToFullHistoryActive)) {
                NavigationView {
                    ResultListView(results: viewStore.statistics.results)
                        .navigationTitle("History")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .overlay(
                    ExitButtonView {
                        viewStore.send(.didPressExitFullHistoryButton)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(Self.exitFullHistoryButtonPadding)
                )
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        viewStore.send(.didPressDeleteButton)
                    } label: {
                        Image(systemName: "trash")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.customRed)
                    }
                }
            }
        }
    }
}

// MARK: - Constants

private extension DrillLogView {
    static let chartAspectRatio: CGFloat = 0.9
    static let minimumResultCount: Int = 2
    static let exitFullHistoryButtonPadding: CGFloat = 12
    static let showFullHistoryButtonBottomPadding: CGFloat = 8
}

// MARK: - Previews

struct DrillLogView_Previews: PreviewProvider {
    static let store = Store(
        initialState: DrillLog.State(
            drill: PersistenceClient.mockDrill
        ),
        reducer: DrillLog()
    )

    static var previews: some View {
        NavigationView {
            DrillLogView(store: store)
        }
    }
}

struct EmptyDrillLogView_Previews: PreviewProvider {
    static let drill = {
        let drill = PersistenceClient.mockDrill
        let results = drill.results
        results.forEach { drill.removeFromResultsValue($0) }
        return drill
    }()

    static let store = Store(
        initialState: DrillLog.State(drill: drill),
        reducer: DrillLog()
    )

    static var previews: some View {
        NavigationView {
            DrillLogView(store: store)
        }
    }
}
