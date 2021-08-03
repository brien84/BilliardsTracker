//
//  ResultsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-05.
//

import SwiftUI

struct ResultsView: View {
    private let results: [DrillResult]

    init(results: [DrillResult]) {
        self.results = results
    }

    var body: some View {
        ScrollView {
            ForEach(results) { result in
                ResultView(result: result)
                Divider()
            }
        }
    }
}

// swiftlint:disable force_try
struct ResultsView_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var results = store.loadDrills().first!.results

    static var view: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ResultsView(results: results)
                .padding()
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
