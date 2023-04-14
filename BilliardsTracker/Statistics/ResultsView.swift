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
        ZStack {
            Color.secondaryBackground

            ScrollView {
                LazyVStack {
                    ForEach(results) { result in
                        Text(result.date.asString)
                            .font(.caption)
                            .foregroundColor(.secondaryElement)
                            .padding([.horizontal, .top])

                        HStack {
                            Text("\(result.potCount)")
                                .font(.title.weight(.medium))
                                .foregroundColor(.customGreen)
                                .frame(maxWidth: .infinity)

                            Text("\(result.pottingPercentage)%")
                                .font(.title3)
                                .foregroundColor(.secondaryElement)
                                .frame(maxWidth: .infinity)

                            Text("\(result.missCount)")
                                .font(.title.weight(.medium))
                                .foregroundColor(.customRed)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()

                        Divider()
                    }
                }
            }
        }
    }
}

private extension Date {
    var asString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - Previews

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(results: PersistenceClient.mockDrill.results)
    }
}
