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
