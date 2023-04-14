//
//  DetailedStatisticsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-14.
//

import SwiftUI

struct DetailedStatisticsView: View {
    let statistics: StatisticsClient

    var body: some View {
        Text("\(statistics.results.count)")
    }
}
