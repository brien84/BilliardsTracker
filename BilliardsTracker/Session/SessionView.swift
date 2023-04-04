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
                            IllustratedTextView(
                                imageName: "rebound",
                                text: "Waiting for results..."
                            )
                            .offset(Self.textViewOffset)
                        } else {
                            ResultsView(results: viewStore.statistics.results)
                        }
                    }
                }
            }
            .alert(
                store.scope(state: \.alert),
                dismiss: .alertDidDismiss
            )
        }
    }
}

// MARK: - Constants

private extension SessionView {
    static let textViewOffset: CGSize = CGSize(width: 0, height: -24)
}

// MARK: - Previews

struct SessionView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(drill: PersistenceClient.mockDrill, startDate: Date()),
        reducer: Session()
    )

    static var previews: some View {
        SessionView(store: store)
    }
}

struct SessionViewWaitingLabel_Previews: PreviewProvider {
    static let drill = {
        let drill = PersistenceClient.mockDrill
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
