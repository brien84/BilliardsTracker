//
//  BilliardsTrackerApp.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import ComposableArchitecture
import SwiftUI

@main
struct BilliardsTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(store: Store(initialState: Main.State(), reducer: Main()))
        }
    }
}
