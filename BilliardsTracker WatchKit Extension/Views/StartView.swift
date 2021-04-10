//
//  StartView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var runner: DrillRunner

    @State private var attempts = 15

    var body: some View {
        if runner.mode == .standalone {
            VStack {
                Picker(selection: $attempts, label: EmptyView()) {
                    ForEach(1..<101, id: \.self) { int in
                        Text(String(int))
                            .font(int == attempts ? .title2 : .title3)
                    }
                }

                Button("Start") {
                    runner.setAttempts(attempts)
                    runner.isActive = true
                }
            }
        }

        if runner.mode == .paired {
            Text("Select drill on a paired iOS device.")
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(DrillRunner())
    }
}
