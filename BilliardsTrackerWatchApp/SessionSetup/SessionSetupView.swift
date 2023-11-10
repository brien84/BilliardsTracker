//
//  SessionSetupView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-08.
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
                        get: \.isNavigationToShotCountActive,
                        send: SessionSetup.Action.setNavigationToShotCount(isActive:)
                    ),
                    destination: {
                        ShotCountPicker(store: store)
                            .foregroundStyle(Color.customBlue)
                            .tint(Color.customBlue)
                    }
                )

                List {
                    SetupButtonView(
                        action: { viewStore.send(.setNavigationToShotCount(isActive: true)) },
                        imageName: "checklist",
                        title: "Shot Count",
                        subtitle: "\(viewStore.shotCount)"
                    )
                    .color(.customBlue)
                }
            }
            .navigationTitle {
                Text("Standalone")
                    .foregroundStyle(Color.customBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let store = Store(
        initialState: SessionSetup.State(mode: .standalone),
        reducer: SessionSetup()
    )

    return SessionSetupView(store: store)
}
