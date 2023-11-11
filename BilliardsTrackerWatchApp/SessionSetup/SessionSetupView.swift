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
                        get: \.isNavigationToContinuousToggleActive,
                        send: SessionSetup.Action.setNavigationToContinuousToggle(isActive:)
                    ),
                    destination: {
                        ContinuousToggle(store: store)
                            .tint(Color.customBlue)
                    }
                )

                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToRestartingToggleActive,
                        send: SessionSetup.Action.setNavigationToRestartingToggle(isActive:)
                    ),
                    destination: {
                        RestartingToggle(store: store)
                            .tint(Color.customBlue)
                    }
                )

                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToShotCountPickerActive,
                        send: SessionSetup.Action.setNavigationToShotCountPicker(isActive:)
                    ),
                    destination: {
                        ShotCountPicker(store: store)
                            .foregroundStyle(Color.customBlue)
                            .tint(Color.customBlue)
                    }
                )

                List {
                    SetupButtonView(
                        action: { viewStore.send(.setNavigationToShotCountPicker(isActive: true)) },
                        imageName: "checklist",
                        title: "Shot Count",
                        subtitle: "\(viewStore.shotCount)"
                    )
                    .color(.customBlue)

                    SetupButtonView(
                        action: { viewStore.send(.setNavigationToContinuousToggle(isActive: true)) },
                        imageName: "repeat",
                        title: "Continuous",
                        subtitle: viewStore.isContinuous ? "Yes" : "No"
                    )
                    .color(.customBlue)

                    SetupButtonView(
                        action: { viewStore.send(.setNavigationToRestartingToggle(isActive: true)) },
                        imageName: "restart",
                        title: "Restarting",
                        subtitle: viewStore.isRestarting ? "Yes" : "No"
                    )
                    .color(.customBlue)
                    .disabled(viewStore.isContinuous)
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
