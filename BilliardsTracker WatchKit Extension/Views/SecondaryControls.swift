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
                runner.isActive = true
            } label: {
                Text("Restart")
                    .foregroundColor(.orange)
            }

            Button {
                runner.isPaused = !runner.isPaused
            } label: {
                Text(runner.isPaused ? "Resume" : "Pause")
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct SecondaryControls_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryControls()
            .environmentObject(DrillRunner())
    }
}
