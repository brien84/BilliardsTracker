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
                .padding()

            Button {
                runner.isActive = false
            } label: {
                Text("Done")
            }

            Button {
                runner.isActive = true
            } label: {
                Text("Restart")
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
