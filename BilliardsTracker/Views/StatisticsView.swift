//
//  StatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct StatisticsView: View {
    private let drill: Drill
    private let statistics: StatisticsManager

    init(drill: Drill) {
        self.drill = drill
        self.statistics = StatisticsManager(drill: drill)
    }

    var body: some View {
        VStack(spacing: 0) {

            VStack(alignment: .leading) {
                HStack {
                    Text("\(statistics.results.count) sessions")
                        .font(.callout)
                        .fontWeight(.light)
                    Spacer()
                    Text("\(statistics.totalAttempts) attempts")
                        .font(.callout)
                        .fontWeight(.light)
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.red)

            HStack {
                VStack {
                    Text("\(statistics.totalPotCount)")
                        .font(.title2)
                    Text("Pots")
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("\(statistics.totalMissCount)")
                        .font(.title2)
                    Text("Misses")
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("\(statistics.pottingPercentage)%")
                        .font(.title2)
                    Text("Average")
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)

            Text("Last results")
                .font(.title)
                .bold()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            ChartView(results: drill.results, maxValue: drill.attempts)
                .padding()
                .background(Color.yellow)
        }
        .navigationBarTitle(drill.title)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))
    static var drill = manager.drills.first!

    static var previews: some View {
        StatisticsView(drill: drill)
    }
}
