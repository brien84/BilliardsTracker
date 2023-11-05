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

    struct ViewState: Equatable {
        let currentTab: Mode

        let isNavigationToOnboardActive: Bool
        let isNavigationToSessionSetupActive: Bool

        init(state: Main.State) {
            self.currentTab = state.currentTab

            self.isNavigationToOnboardActive = state.isNavigationToOnboardActive
            self.isNavigationToSessionSetupActive = state.isNavigationToSessionSetupActive
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
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

                    List {
                        MenuButtonView(
                            imageName: "applewatch",
                            title: "Standalone",
                            subtitle: ""
                        ) {
                            viewStore.send(.didChangeCurrentTab(.standalone))
                            viewStore.send(.setNavigationToSessionSetup(isActive: true))
                        }
                        .setColor(.customBlue)

                        MenuButtonView(
                            imageName: "iphone",
                            title: "Tracked",
                            subtitle: ""
                        ) {
                            viewStore.send(.didChangeCurrentTab(.tracked))
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
