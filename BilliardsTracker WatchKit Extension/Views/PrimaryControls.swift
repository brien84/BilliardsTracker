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

            VStack {
                HStack {
                    Button {
                        runner.add(.pot)
                    } label: {
                        Text(String(runner.potCount))
                            .foregroundColor(.green)
                    }

                    Button {
                        runner.add(.miss)
                    } label: {
                        Text(String(runner.missCount))
                            .foregroundColor(.red)
                    }
                }.disabled(runner.isCompleted)

                HStack {
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
    }
}

struct PrimaryControls_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryControls()
            .environmentObject(DrillRunner())
    }
}
