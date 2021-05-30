//
//  BilliardsTrackerApp.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

@main
struct BilliardsTrackerApp: App {
    private let store: DrillStore? = try? DrillStore()

    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label
    }

    var body: some Scene {
        WindowGroup {
            if store == nil {
                Color.clear
                    .alert(isPresented: .constant(true)) {
                        Alert(title: Text("Something went terribly wrong!"),
                              message: Text("Please restart BilliardsTracker. If the error persists reinstall the application."),
                              dismissButton: .default(Text("OK"), action: { fatalError() })
                        )
                    }
            } else {
                DrillsView()
                    .environmentObject(DrillManager(store: store!))
            }
        }
    }
}
