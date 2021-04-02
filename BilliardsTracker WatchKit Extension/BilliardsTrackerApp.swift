//
//  BilliardsTrackerApp.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

@main
struct BilliardsTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(DrillRunner())
            }
        }
    }
}
