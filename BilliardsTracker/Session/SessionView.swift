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
                        .id(viewStore.statistics.results.count)

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

// MARK: - Constants

private extension SessionView {
    static let waitingLabelOffset: CGSize = CGSize(width: 0, height: -32)
}

private extension WaitingLabelView {
    static let spacing: CGFloat = 16
    static let width: CGFloat = 100
    static let height: CGFloat = 100
}

// MARK: - Previews

struct SessionView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(drill: PersistenceClient.previewData.first!, startDate: Date()),
        reducer: Session()
    )

    static var previews: some View {
        SessionView(store: store)
    }
}
