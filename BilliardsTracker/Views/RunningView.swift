//
//  RunningView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct RunningView: View {
    @EnvironmentObject var manager: DrillManager

    var body: some View {
        VStack {
            Text("Running: \(manager.selectedDrill?.title ?? "")")

            List {
                ForEach(manager.currentSessionResults) { result in
                    ResultView(result: result)
                }.listRowBackground(Color.blue)
            }

        }
    }
}

struct RunningView_Previews: PreviewProvider {
    static var manager: DrillManager = {
        let manager = DrillManager(store: DrillStore(inMemory: true))
        manager.selectedDrill = manager.drills.first!
        return manager
    }()

    static var previews: some View {
        RunningView()
            .environmentObject(manager)
    }
}
