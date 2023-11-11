//
//  MenuView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-13.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    PassiveNavigationLink(
                        isActive: viewStore.binding(
                            get: \.isNavigationToOnboardActive,
                            send: Main.Action.setNavigationToOnboard(isActive:)
                        ),
                        destination: { OnboardView() }
                    )

                    PassiveNavigationLink(
                        isActive: viewStore.binding(
                            get: \.isNavigationToStandaloneActive,
                            send: Main.Action.setNavigationToStandalone(isActive:)
                        ),
                        destination: {
                            SessionView(store: store.scope(
                                state: \.standalone,
                                action: Main.Action.standalone
                            ))
                        }
                    )

                    PassiveNavigationLink(
                        isActive: viewStore.binding(
                            get: \.isNavigationToStandaloneSetupActive,
                            send: Main.Action.setNavigationToStandaloneSetup(isActive:)
                        ),
                        destination: {
                            SessionSetupView(store: store.scope(
                                state: \.standaloneSetup,
                                action: Main.Action.standaloneSetup
                            ))
                        }
                    )

                    PassiveNavigationLink(
                        isActive: viewStore.binding(
                            get: \.isNavigationToTrackedActive,
                            send: Main.Action.setNavigationToTracked(isActive:)
                        ),
                        destination: {
                            TrackedActivationView(store: store.scope(
                                state: \.tracked,
                                action: Main.Action.tracked
                            ))
                        }
                    )

                    PassiveNavigationLink(
                        isActive: viewStore.binding(
                            get: \.isNavigationToTrackedSetupActive,
                            send: Main.Action.setNavigationToTrackedSetup(isActive:)
                        ),
                        destination: {
                            SessionSetupView(store: store.scope(
                                state: \.trackedSetup,
                                action: Main.Action.trackedSetup
                            ))
                        }
                    )

                    List {
                        let shots = String(viewStore.standaloneSetup.shotCount) + " shots"
                        let isContinuous = viewStore.standaloneSetup.isContinuous ? " | continuous" : ""
                        ListButtonView(
                            title: "Standalone",
                            action: {
                                viewStore.send(.setNavigationToStandalone(isActive: true))
                            },
                            secondaryAction: {
                                viewStore.send(.setNavigationToStandaloneSetup(isActive: true))
                            }
                        )
                        .color(.customBlue)
                        .imageName("applewatch")
                        .subtitle(shots + isContinuous)

                        ListButtonView(
                            title: "Tracked",
                            action: {
                                viewStore.send(.setNavigationToTracked(isActive: true))
                            },
                            secondaryAction: {
                                viewStore.send(.setNavigationToTrackedSetup(isActive: true))
                            }
                        )
                        .color(.customRed)
                        .imageName("iphone")
                    }
                    .listStyle(.carousel)
                }
                .task {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
    }
}
