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
                            get: \.isNavigationToSessionSetupActive,
                            send: Main.Action.setNavigationToSessionSetup(isActive:)
                        ),
                        destination: {
                            SessionSetupView(store: store.scope(
                                state: \.sessionSetup,
                                action: Main.Action.sessionSetup
                            ))
                        }
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

                    List {
                        MenuButtonView(
                            imageName: "applewatch",
                            title: "Standalone",
                            subtitle: ""
                        ) {
                            viewStore.send(.setNavigationToStandalone(isActive: true))
                        }
                        .setColor(.customBlue)

                        MenuButtonView(
                            imageName: "iphone",
                            title: "Tracked",
                            subtitle: ""
                        ) {
                            viewStore.send(.setNavigationToSessionSetup(isActive: true))
                        }
                        .setColor(.customRed)
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
