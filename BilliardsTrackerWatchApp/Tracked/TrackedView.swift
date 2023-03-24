//
//  TrackedView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-03-06.
//

import ComposableArchitecture
import SwiftUI

struct TrackedView: View {
    let store: StoreOf<Tracked>

    struct ViewState: Equatable {
        let isNavigationToSessionActive: Bool

        init(state: Tracked.State) {
            self.isNavigationToSessionActive = state.session != nil
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            ZStack {
                Text("Select a drill on BilliardsTracker iPhone app.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.primaryElement)

                IfLetStore(
                    store.scope(
                        state: \.session,
                        action: Tracked.Action.session
                    ),
                    then: SessionView.init(store:)
                )
                .transition(.slide)
                .zIndex(1)
            }
            .navigationBarBackButtonHidden(viewStore.isNavigationToSessionActive)
            .onAppear {
                viewStore.send(.establishConnection)
            }
            .onDisappear {
                viewStore.send(.stopConnection)
            }
        }
    }
}

// MARK: - Previews

struct TrackedView_Previews: PreviewProvider {
    static var previews: some View {
        TrackedView(store: Store(initialState: Tracked.State(), reducer: Tracked()))
    }
}
