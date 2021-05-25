//
//  PrimaryControls.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct PrimaryControls: View {
    @EnvironmentObject var runner: DrillRunner

    var body: some View {
        VStack {
            Text(String(runner.remainingAttempts))
                .padding()
                .font(.title2)

            HStack {
                Button {
                    runner.addAttempt(isSuccess: true)
                } label: {
                    Text(String(runner.potCount))
                        .foregroundColor(.green)
                }

                Button {
                    runner.addAttempt(isSuccess: false)
                } label: {
                    Text(String(runner.missCount))
                        .foregroundColor(.red)
                }
            }
            .disabled(runner.isPaused)

        }
    }
}

struct PrimaryControls_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryControls()
            .environmentObject(DrillRunner())
    }
}
