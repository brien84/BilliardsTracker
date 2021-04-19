//
//  RunningView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct RunningView: View {
    @EnvironmentObject var manager: DrillManager
    private let drill: Drill

    init(drill: Drill) {
        self.drill = drill
    }

    var body: some View {
        VStack {
            Text("Running: \(drill.title)")

            List(drill.results) { result in

                VStack {
                    HStack {
                        Text(String(result.potCount))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.green)

                        Text(String(result.missCount))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .font(.title)

                    Text(String("\(result.date)"))
                        .font(.body)
                }

            }
        }
    }
}

struct RunningView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))
    static var drill = manager.drills.first!

    static var previews: some View {
        RunningView(drill: drill)
            .environmentObject(manager)
    }
}
