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

    @State private var currentTab = Tab.standalone

    private enum Tab: Int {
        case standalone, tracked
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    PassiveNavigationLink(
                        isActive: viewStore.binding(\.$isNavigationToOnboardActive),
                        destination: { OnboardView() }
                    )

                    PassiveNavigationLink(
                        isActive: viewStore.binding(\.$isNavigationToStandaloneActive),
                        destination: { SessionView(.standalone) }
                    )

                    PassiveNavigationLink(
                        isActive: viewStore.binding(\.$isNavigationToTrackedActive),
                        destination: { SessionView(.tracked) }
                    )

                    TabView(selection: $currentTab) {
                        NavigationButton(
                            title: "Standalone",
                            isActive: viewStore.binding(\.$isNavigationToStandaloneActive)
                        )
                        .foregroundColor(.customBlue)
                        .tag(Tab.standalone)

                        NavigationButton(
                            title: "Tracked",
                            isActive: viewStore.binding(\.$isNavigationToTrackedActive)
                        )
                        .foregroundColor(.customRed)
                        .tag(Tab.tracked)
                    }
                }
            }
            .environmentObject(viewStore.session)
        }
    }
}

private struct NavigationButton: View {
    let title: String
    @Binding var isActive: Bool

    @State private var titleScale = Self.minimumTitleScale

    var body: some View {
        Button {
            isActive = true
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

private extension NavigationButton {
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
