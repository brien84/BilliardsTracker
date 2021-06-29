//
//  BilliardsTrackerApp.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

@main
struct BilliardsTrackerApp: App {
    @ObservedObject var runner = SessionManager()

    @State private var showOnboard = false

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ZStack {
                    NavigationLink(
                        destination: OnboardView(),
                        isActive: $showOnboard,
                        label: {
                            Color.clear
                        })

                    MenuView()
                }
            }
            .environmentObject(runner)
            .onAppear {
                if UserDefaults.standard.object(forKey: .userDefaultsOnboardKey) == nil {
                    showOnboard = true
                    UserDefaults.standard.set(true, forKey: .userDefaultsOnboardKey)
                }
            }
        }
    }
}

private extension String {
    static var userDefaultsOnboardKey: String {
        "userDefaultsOnboardKey"
    }
}
