//
//  ResultsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-05.
//

import SwiftUI

struct ResultsView: View {
    let results: [DrillResult]

    var body: some View {
        ScrollView {
            ForEach(results) { result in
                ZStack {
                    Color.secondaryBackground

                    VStack {
                        Text("\(result.date.asString)")
                            .font(.caption)
                            .foregroundColor(.secondaryElement)
                            .padding([.horizontal, .top])

                        HStack {
                            Text("\(result.potCount)")
                                .frame(maxWidth: .infinity)
                                .font(.title)
                                .foregroundColor(.customGreen)

                            Text("\(result.pottingPercentage)%")
                                .frame(maxWidth: .infinity)
                                .font(.title3)
                                .foregroundColor(.secondaryElement)

                            Text("\(result.missCount)")
                                .frame(maxWidth: .infinity)
                                .font(Font.title)
                                .foregroundColor(.customRed)
                        }
                        .padding()
                    }
                }

                Divider()
            }
        }
    }
}
