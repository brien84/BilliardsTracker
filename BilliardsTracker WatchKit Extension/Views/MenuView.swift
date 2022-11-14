//
//  MenuView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-10.
//

import SwiftUI

struct MenuView: View {
    @State private var currentTab = MenuTab.standalone
    @State private var isNavigationToStandaloneActive = false
    @State private var isNavigationToTrackedActive = false
    @State private var isNavigationToOnboardActive = false

    private enum MenuTab: Int {
        case standalone, tracked
    }

    var body: some View {
        ZStack {
            PassiveNavigationLink(
                isActive: $isNavigationToOnboardActive,
                destination: OnboardView()
            )

            PassiveNavigationLink(
                isActive: $isNavigationToStandaloneActive,
                destination: SessionView(.standalone)
            )

            PassiveNavigationLink(
                isActive: $isNavigationToTrackedActive,
                destination: SessionView(.tracked)
            )

            TabView(selection: $currentTab) {
                MenuButton(title: "Standalone") {
                    isNavigationToStandaloneActive = true
                }
                .foregroundColor(.customBlue)
                .tag(MenuTab.standalone)

                MenuButton(title: "Tracked") {
                    isNavigationToTrackedActive = true
                }
                .foregroundColor(.customRed)
                .tag(MenuTab.tracked)
            }
        }
        .onAppear {
            if UserDefaults.standard.object(forKey: .userDefaultsOnboardKey) == nil {
                isNavigationToOnboardActive = true
                UserDefaults.standard.set(true, forKey: .userDefaultsOnboardKey)
            }
        }
    }
}

private struct PassiveNavigationLink<Destination>: View where Destination: View {
    let isActive: Binding<Bool>
    let destination: Destination

    var body: some View {
        NavigationLink(
            isActive: isActive,
            destination: { destination },
            label: { EmptyView() }
        )
        .buttonStyle(.plain)
        .disabled(true)
        .hidden()
    }
}

private struct MenuButton: View {
    let title: String
    let action: () -> Void

    @State private var titleScale: CGFloat = .defaultMenuButtonTitleScale

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.title3)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(titleScale)
        .onAppear {
            let animation = Animation.easeInOut(duration: .defaultAnimationDuration)
                                     .repeatForever(autoreverses: true)

            DispatchQueue.main.async {
                withAnimation(animation) {
                    titleScale = .maximumMenuButtonTitleScale
                }
            }
        }
    }
}

private extension Double {
    static var defaultAnimationDuration: Double {
        1.0
    }
}

private extension CGFloat {
    static var defaultMenuButtonTitleScale: CGFloat {
        1.0
    }

    static var maximumMenuButtonTitleScale: CGFloat {
        1.1
    }
}

private extension String {
    static var userDefaultsOnboardKey: String {
        "userDefaultsOnboardKey"
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
