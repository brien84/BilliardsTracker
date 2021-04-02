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
        Text("Drill completed!")
    }
}

struct CompletionView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionView()
            .environmentObject(DrillRunner())
    }
}
