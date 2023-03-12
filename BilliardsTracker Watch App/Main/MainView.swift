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
        let currentTab: Main.Tab

        let isNavigationToOnboardActive: Bool
        let isNavigationToStandaloneActive: Bool
        let isNavigationToTrackedActive: Bool

        init(state: Main.State) {
            self.currentTab = state.currentTab

            self.isNavigationToOnboardActive = state.isNavigationToOnboardActive
            self.isNavigationToStandaloneActive = state.isNavigationToStandaloneActive
            self.isNavigationToTrackedActive = state.isNavigationToTrackedActive
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
                            get: \.isNavigationToStandaloneActive,
                            send: Main.Action.setNavigationToStandalone(isActive:)
                        ),
                        destination: {
                            StandaloneView(store: store.scope(
                                state: \.standalone,
                                action: Main.Action.standalone
                            ))
                        }
                    )

                    PassiveNavigationLink(
                        isActive: viewStore.binding(
                            get: \.isNavigationToTrackedActive,
                            send: Main.Action.setNavigationToTracked(isActive:)
                        ),
                        destination: {
                            TrackedView(store: store.scope(
                                state: \.tracked,
                                action: Main.Action.tracked
                            ))
                        }
                    )

                    TabView(selection:
                        viewStore.binding(
                            get: \.currentTab,
                            send: Main.Action.didChangeCurrentTab
                        )
                    ) {
                        TabViewButton(title: "Standalone") {
                            viewStore.send(.setNavigationToStandalone(isActive: true))
                        }
                        .foregroundColor(.customBlue)
                        .tag(Main.Tab.standalone)

                        TabViewButton(title: "Tracked") {
                            viewStore.send(.setNavigationToTracked(isActive: true))
                        }
                        .foregroundColor(.customRed)
                        .tag(Main.Tab.tracked)
                    }
                }
            }
        }
    }
}

private struct TabViewButton: View {
    let title: String
    let action: () -> Void

    @State private var titleScale = Self.minimumTitleScale

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.title3)
                .scaleEffect(titleScale)
        }
        .buttonStyle(.plain)
        .task {
            withAnimation(Self.titleScaleAnimation) {
                titleScale = Self.maximumTitleScale
            }
        }
    }
}

// MARK: - Constants

private extension TabViewButton {
    static let minimumTitleScale: CGFloat = 1.0
    static let maximumTitleScale: CGFloat = 1.1
    static let titleScaleAnimation: Animation = .easeInOut(duration: 1.0).repeatForever()
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
    }
}
