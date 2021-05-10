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
                runner.isPaused = !runner.isPaused
            } label: {
                Text(runner.isPaused ? "Resume" : "Pause")
                    .foregroundColor(.yellow)
            }

            Button {
                runner.isActive = false
            } label: {
                Text("Stop")
                    .foregroundColor(.red)
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
