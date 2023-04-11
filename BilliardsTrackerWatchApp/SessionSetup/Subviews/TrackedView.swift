//
//  TrackedView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-03-06.
//

import ComposableArchitecture
import SwiftUI

private extension TrackedView {
    struct State: Equatable {
        var isNavigationToSessionActive: Bool
    }

    enum Action: Equatable {
        case establishConnection
        case endConnection
    }
}

private extension SessionSetup.State {
    var state: TrackedView.State {
        .init(isNavigationToSessionActive: isNavigationToSessionActive)
    }
}

private extension TrackedView.Action {
    var action: SessionSetup.Action {
        switch self {
        case .establishConnection:
            return .establishConnection
        case .endConnection:
            return .endConnection
        }
    }
}

struct TrackedView: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            ZStack {
                Text("Select a drill on BilliardsTracker iPhone app.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.primaryElement)
            }
            .navigationBarBackButtonHidden(viewStore.isNavigationToSessionActive)
            .onAppear {
                viewStore.send(.establishConnection)
            }
            .onDisappear {
                viewStore.send(.endConnection)
            }
        }
    }
}

// MARK: - Previews

struct TrackedView_Previews: PreviewProvider {
    static let store = Store(
        initialState: SessionSetup.State(mode: .tracked),
        reducer: SessionSetup()
    )

    static var previews: some View {
        TrackedView(store: store)
    }
}
