//
//  CompletionView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct CompletionView: View {
    @EnvironmentObject var runner: DrillRunner

    var body: some View {
        VStack {
            Text("Drill completed!")

            HStack {
                Text(String(runner.potCount))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                Text(String(runner.missCount))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .font(.title3)

            Button {
                runner.isActive = true
            } label: {
                Text("Restart")
            }

            Button {
                runner.isActive = false
            } label: {
                Text("Done")
            }
        }
    }
}

struct CompletionView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionView()
            .environmentObject(DrillRunner())
    }
}
