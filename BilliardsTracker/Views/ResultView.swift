//
//  ResultView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-05-06.
//

import SwiftUI

struct ResultView: View {
    private let result: DrillResult

    init(result: DrillResult) {
        self.result = result
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0)
                .foregroundColor(.white)

            VStack {
                Text(String(result.date.asString))
                    .foregroundColor(.gray)
                    .font(.caption)

                HStack {
                    Text(String(result.potCount))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.green)
                        .font(.title)

                    Text("\(result.pottingPercentage)%")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .font(.title3)

                    Text(String(result.missCount))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                        .font(.title)
                }
                .padding()
            }
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))
    static var result = manager.drills.first!.results.first!

    static var previews: some View {
        List {
            ResultView(result: result)
                .listRowBackground(Color.blue)
        }
    }
}
