//
//  DrillListView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import ComposableArchitecture
import SwiftUI

struct DrillListView: View {
    let store: StoreOf<DrillList>

    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if viewStore.drillItems.isEmpty && isEnabled {
                    EmptyDrillListPrompt {
                        viewStore.send(.didTapNewDrillButton)
                    }
                    .padding()
                    .transition(.slide)
                }

                LazyVStack(spacing: Self.verticalSpacing) {
                    ForEachStore(
                        store.scope(
                            state: \.drillItems,
                            action: DrillList.Action.drillItem(id:action:)
                        )
                    ) {
                        DrillItemView(store: $0)
                            .padding(.horizontal)
                            .transition(.slide)
                    }
                }
            }
        }
    }
}

// MARK: - Constants

private extension DrillListView {
    static let verticalSpacing: CGFloat = 16
}

// MARK: - Previews

struct DrillListView_Previews: PreviewProvider {
    static let drills = [
        PersistenceClient.mockDrill,
        PersistenceClient.mockDrill,
        PersistenceClient.mockDrill,
        PersistenceClient.mockDrill,
        PersistenceClient.mockDrill
    ]

    static let store = Store(
        initialState: DrillList.State(drills: drills),
        reducer: DrillList()
    )

    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            DrillListView(store: store)
        }
    }
}
