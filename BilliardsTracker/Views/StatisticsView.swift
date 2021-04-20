//
//  StatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct StatisticsView: View {
    private let drill: Drill

    init(drill: Drill) {
        self.drill = drill
    }

    var body: some View {
        Text(drill.title)
            .font(.title)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))
    static var drill = manager.drills.first!

    static var previews: some View {
        StatisticsView(drill: drill)
    }
}
