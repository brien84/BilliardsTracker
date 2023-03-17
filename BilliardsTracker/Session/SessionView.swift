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
                    HStack {
                        Text(viewStore.drill.title)
                            .lineLimit(2)
                            .font(.largeTitle.bold())
                            .foregroundColor(.primaryElement)

                        Spacer()

                        ExitButtonView {
                            viewStore.send(.didTapExitButton)
                        }
                    }
                    .padding()

                    StatisticsPanel(statistics: viewStore.statistics)
                        .animation(.none, value: viewStore.statistics)

                    CardView(title: "Results") {
                        if viewStore.statistics.results.isEmpty {
                            WaitingLabelView()
                        } else {
                            ResultsView(results: viewStore.statistics.results)
                        }
                    }
                }
            }
        }
    }
}

private struct WaitingLabelView: View {
    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            Image("table")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Self.width, height: Self.height)

            Text("Waiting for results...")
                .font(.headline)
                .foregroundColor(.primaryElement)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(Self.offset)
    }
}

// MARK: - Constants

private extension WaitingLabelView {
    static let verticalSpacing: CGFloat = 16
    static let width: CGFloat = 100
    static let height: CGFloat = 100
    static let offset: CGSize = CGSize(width: 0, height: -24)
}

// MARK: - Previews

struct SessionView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(drill: PersistenceClient.previewDrill, startDate: Date()),
        reducer: Session()
    )

    static var previews: some View {
        SessionView(store: store)
    }
}

struct SessionViewWaitingLabel_Previews: PreviewProvider {
    static let drill = {
        let drill = PersistenceClient.previewDrill
        let results = drill.results
        results.forEach { drill.removeFromResultsValue($0) }
        return drill
    }()

    static let store = Store(
        initialState: Session.State(drill: drill, startDate: Date()),
        reducer: Session()
    )

    static var previews: some View {
        SessionView(store: store)
    }
}
