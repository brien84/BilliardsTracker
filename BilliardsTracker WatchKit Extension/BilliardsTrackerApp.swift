//
//  BilliardsTrackerApp.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

@main
struct BilliardsTrackerApp: App {
    @StateObject var session = SessionManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                MenuView()
            }
            .environmentObject(session)
        }
    }
}
