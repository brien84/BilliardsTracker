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
        HStack {
            Button {
                runner.addPot()
            } label: {
                Text(String(runner.potCount))
                    .foregroundColor(.green)
            }

            Button {
                runner.addMiss()
            } label: {
                Text(String(runner.missCount))
                    .foregroundColor(.red)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
