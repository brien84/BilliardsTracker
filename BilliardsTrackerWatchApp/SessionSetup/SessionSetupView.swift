//
//  SessionSetupView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-08.
//

import ComposableArchitecture
import SwiftUI

protocol SessionSetupSubview: View {
    var color: Color { get set }
}

struct SessionSetupView: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store) { viewStore in
            let color = viewStore.mode == .standalone ? Color.customBlue : Color.customRed

            ZStack {
                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToContinuousToggleActive,
                        send: SessionSetup.Action.setNavigationToContinuousToggle(isActive:)
                    ),
                    destination: {
                        ContinuousToggle(store: store)
                            .color(color)
                    }
                )

                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToGesturesToggleActive,
                        send: SessionSetup.Action.setNavigationToGesturesToggle(isActive:)
                    ),
                    destination: {
                        GesturesToggle(store: store)
                            .color(color)
                    }
                )

                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToRestartingToggleActive,
                        send: SessionSetup.Action.setNavigationToRestartingToggle(isActive:)
                    ),
                    destination: {
                        RestartingToggle(store: store)
                            .color(color)
                    }
                )

                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToShotCountPickerActive,
                        send: SessionSetup.Action.setNavigationToShotCountPicker(isActive:)
                    ),
                    destination: {
                        ShotCountPicker(store: store)
                            .color(color)
                    }
                )

                List {
                    if viewStore.mode == .standalone {
                        SetupButtonView(
                            action: { viewStore.send(.setNavigationToShotCountPicker(isActive: true)) },
                            imageName: "checklist",
                            title: "Shot Count",
                            subtitle: "\(viewStore.shotCount)"
                        )
                        .color(color)

                        SetupButtonView(
                            action: { viewStore.send(.setNavigationToContinuousToggle(isActive: true)) },
                            imageName: "repeat",
                            title: "Continuous",
                            subtitle: viewStore.isContinuous ? "Yes" : "No"
                        )
                        .color(color)

                        SetupButtonView(
                            action: { viewStore.send(.setNavigationToRestartingToggle(isActive: true)) },
                            imageName: "restart",
                            title: "Restarting",
                            subtitle: viewStore.isRestarting ? "Yes" : "No"
                        )
                        .color(color)
                        .disabled(viewStore.isContinuous)
                    }

                    SetupButtonView(
                        action: { viewStore.send(.setNavigationToGesturesToggle(isActive: true)) },
                        imageName: "hand.draw",
                        title: "Gestures",
                        subtitle: viewStore.gesturesEnabled ? "Enabled" : "Disabled"
                    )
                    .color(color)
                }
            }
            .navigationTitle {
                Text(viewStore.mode == .standalone ? "Standalone" : "Tracked")
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

extension SessionSetupSubview {
    static var tintOpacity: CGFloat { 0.15 }

    func color(_ color: Color) -> some View {
        var copy = self
        copy.color = color
        return copy
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

#Preview {
    let store = Store(
        initialState: SessionSetup.State(mode: .tracked),
        reducer: SessionSetup()
    )

    return SessionSetupView(store: store)
}
