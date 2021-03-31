//
//  ContentView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var runner = DrillRunner()

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

                Button {
                    runner.restart()
                } label: {
                    Text("Restart")
                        .foregroundColor(.purple)
                }
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
