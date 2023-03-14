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

    init() {
        // Changes alert tint color.
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label
    }

    var body: some Scene {
        WindowGroup {
            MainView(store: Store(initialState: Main.State(), reducer: Main()))
        }
    }

}
