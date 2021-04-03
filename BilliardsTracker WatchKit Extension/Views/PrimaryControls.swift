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
                    runner.potCount += 1
                } label: {
                    Text(String(runner.potCount))
                        .foregroundColor(.green)
                }

                Button {
                    runner.missCount += 1
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
