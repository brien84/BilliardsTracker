//
//  MenuView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-10.
//

import SwiftUI

struct MenuView: View {
    @State private var currentTab: Int = 0
    @State private var showOnboard = false

    var body: some View {
        ZStack {
            NavigationLink(
                destination: OnboardView(),
                isActive: $showOnboard,
                label: {
                    Color.clear
                })

            TabView(selection: $currentTab) {
                MenuNavigationLink(title: "Standalone") {
                    SessionView(.standalone)
                }
                .foregroundColor(.customBlue)
                .tag(0)

                MenuNavigationLink(title: "Tracked") {
                    SessionView(.tracked)
                }
                .foregroundColor(.customRed)
                .tag(1)
            }

        }
        .onAppear {
            if UserDefaults.standard.object(forKey: .userDefaultsOnboardKey) == nil {
                showOnboard = true
                UserDefaults.standard.set(true, forKey: .userDefaultsOnboardKey)
            }
        }

    }
}

struct MenuNavigationLink<Destination>: View where Destination: View {
    private let title: String
    private let destination: () -> Destination

    @State private var titleScale: CGFloat = 1.0

    init(title: String, @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.destination = destination
    }

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            Text(title)
                .font(.title3)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(titleScale)
        .onAppear {
            let animation = Animation.easeInOut(duration: .animationDuration)
                                     .repeatForever(autoreverses: true)

            withAnimation(animation) {
                titleScale = .navigationLinkTitleMaxScale
            }
        }
    }
}

private extension Double {
    static var animationDuration: Double {
        1.0
    }
}

private extension CGFloat {
    static var navigationLinkTitleMaxScale: CGFloat {
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
