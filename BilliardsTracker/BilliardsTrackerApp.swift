//
//  BilliardsTrackerApp.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import ComposableArchitecture
import SwiftUI

@main
struct BilliardsTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                MainView(store: Store(initialState: Main.State(), reducer: Main()))
            }
        }
    }
}
