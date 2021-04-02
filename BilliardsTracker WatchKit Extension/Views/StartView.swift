//
//  StartView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var runner: DrillRunner

    var body: some View {

        Button("Start") {
            runner.isRunning = true
        }

    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(DrillRunner())
    }
}
