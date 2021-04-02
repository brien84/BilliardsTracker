//
//  SecondaryControls.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct SecondaryControls: View {
    @EnvironmentObject var runner: DrillRunner

    var body: some View {
        VStack {
            Button {
                runner.restart()
            } label: {
                Text("Restart")
                    .foregroundColor(.orange)
            }

            Button {
                runner.toggleRun()
            } label: {
                Text(runner.isRunning ? "Pause" : "Resume")
                    .foregroundColor(.yellow)
            }.disabled(runner.isCompleted)
        }
    }
}

struct SecondaryControls_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryControls()
            .environmentObject(DrillRunner())
    }
}
