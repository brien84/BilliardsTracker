//
//  SessionSetupView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import ComposableArchitecture
import SwiftUI

struct SessionSetupView: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToSessionActive,
                        send: SessionSetup.Action.setNavigationToSession
                    ),
                    destination: {
                        SessionView(store: store.scope(
                            state: \.session,
                            action: SessionSetup.Action.session
                        ))
                    }
                )

                TrackedView(store: store)
            }
        }
    }
}

// MARK: - Previews

struct SessionSetupView_Previews: PreviewProvider {
    static let store = Store(
        initialState: SessionSetup.State(mode: .tracked),
        reducer: SessionSetup()
    )

    static var previews: some View {
        SessionSetupView(store: store)
    }
}
