//
//  SessionView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import ComposableArchitecture
import SwiftUI

struct SessionView: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: .zero) {
                    Button {
                        viewStore.send(.didTapExitButton)
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()

                    SessionStatisticsPanel(store: store)

                    CardView {
                        if viewStore.statistics.results.isEmpty {
                            WaitingLabelView()
                                .offset(Self.waitingLabelOffset)
                        } else {
                            ResultsView(results: viewStore.statistics.results)
                        }
                    }
                    .setTitle("Results")
                }
            }
            .animation(.easeInOut)
            .navigationBarTitle(viewStore.statistics.drill.title)
        }
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
//struct SessionView_Previews: PreviewProvider {
//    static var drillStore = try! DrillStore(inMemory: true, isPreview: true)
//    static var drill = drillStore.loadDrills().first!
//
//    static let store = Store(
//        initialState: Session.State(statistics: StatisticsManager(drill: drill)),
//        reducer: Session()
//    )
//
//    static var previews: some View {
//        NavigationView {
//            SessionView(store: store)
//        }
//    }
//
//}

struct SessionStatisticsPanel: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                let statistics = viewStore.statistics

                HStack {
                    if statistics.results.count == 1 {
                        Text("1 attempt")
                    } else {
                        Text("\(statistics.results.count) attempts")
                    }

                    Spacer()

                    if statistics.attemptsCount == 1 {
                        Text("1 shot")
                    } else {
                        Text("\(statistics.attemptsCount) shots")
                    }
                }
                .frame(maxWidth: .infinity)
                .font(Font.subheadline.weight(.light))
                .foregroundColor(.primaryElement)
                .padding()

                HStack {
                    if statistics.drill.isFailable {
                        StatisticLabel(title: "Completed", value: "\(statistics.failableCompletedCount)")
                            .titleColor(.customGreen)

                        StatisticLabel(title: "Completion", value: "\(statistics.failableCompletionPercentage)%")
                            .titleColor(statistics.failableCompletionPercentage > 50 ? .customGreen : .customRed)

                        StatisticLabel(title: "Average Pots", value: "\(statistics.averagePots)")
                            .titleColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)
                    } else {
                        StatisticLabel(title: "Pots", value: "\(statistics.potCount)")
                            .titleColor(.customGreen)

                        StatisticLabel(title: "Potting", value: "\(statistics.pottingPercentage)%")
                            .titleColor(statistics.pottingPercentage > 50 ? .customGreen : .customRed)

                        StatisticLabel(title: "Misses", value: "\(statistics.missCount)")
                            .titleColor(.customRed)
                    }
                }
                .padding()
            }
        }

    }
}

private struct StatisticLabel: View {
    private var title: String
    private var value: String

    @State private var titleColor = Color.secondaryElement

    var body: some View {
        VStack(spacing: Self.labelVerticalSpacing) {
            Text(value)
                .font(.title2)
                .foregroundColor(titleColor)
            Text(title)
                .font(Font.subheadline.weight(.light))
                .foregroundColor(.secondaryElement)
        }
        .frame(maxWidth: .infinity)
    }

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    func titleColor(_ color: Color) -> some View {
        var view = self
        view._titleColor = State(initialValue: color)
        return view.id(UUID())
    }
}

private extension StatisticLabel {
    static let labelVerticalSpacing: CGFloat = 8
}
