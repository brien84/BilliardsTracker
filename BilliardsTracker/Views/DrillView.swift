//
//  DrillView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct DrillView: View {
    @EnvironmentObject var manager: DrillManager
    private let drill: Drill

    init(drill: Drill) {
        self.drill = drill
    }

    var body: some View {
        Button {
            manager.start(drill: drill)
        } label: {
            VStack(spacing: 16) {
                Text(drill.title)
                    .font(.title)
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .imageScale(.small)
                    Text(String(drill.attempts))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}

struct DrillView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))
    static var drill = manager.drills.first!

    static var previews: some View {
        DrillView(drill: drill)
            .environmentObject(manager)
    }
}
