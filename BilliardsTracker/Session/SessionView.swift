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

                ScrollView {
                    VStack(spacing: .zero) {
                        SectionLabelView(title: "Statistics")

                        StatisticsView(statistics: viewStore.statistics)
                            .animation(.none, value: viewStore.statistics)
                            .roundedBackground()

                        SectionLabelView(title: "Results")

                        Group {
                            if viewStore.statistics.results.isEmpty {
                                IllustratedTextView(
                                    imageName: "rebound",
                                    title: "waiting for results",
                                    subtitle: "results will appear once the drill is completed"
                                )
                                .padding(.horizontal)
                            } else {
                                ResultListView(results: viewStore.statistics.results)
                            }
                        }
                        .roundedBackground()
                        .padding(.bottom)
                        .aspectRatio(Self.aspectRatio, contentMode: .fit)
                    }
                }
            }
            .background(Color.primaryBackground)
            .alert(
                store.scope(state: \.alert),
                dismiss: .alertDidDismiss
            )
        }
    }
}

// MARK: - Constants

private extension SessionView {
    static let aspectRatio: CGFloat = 0.75
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
