//
//  ContentView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var runner: DrillRunner

    @State private var currentTab: Int = 0

    var body: some View {
        if runner.isActive {
            if runner.isCompleted {
                CompletionView()
            } else {
                TabView(selection: $currentTab) {
                    PrimaryControls().tag(0)
                    SecondaryControls().tag(1)
                }
            }
        } else {
            StartView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DrillRunner())
    }
}
