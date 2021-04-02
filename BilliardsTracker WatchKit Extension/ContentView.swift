//
//  ContentView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var runner: DrillRunner

    var body: some View {
        if runner.isRunning {
            PrimaryControls()
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
