//
//  ResultListView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-05.
//

import SwiftUI

struct ResultListView: View {
    let results: [DrillResult]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Self.verticalSpacing) {
                ForEach(results) { result in
                    VStack {
                        Text(result.date.asString)
                            .font(.caption)
                            .foregroundColor(.secondaryElement)

                        HStack {
                            Text("\(result.potCount)")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.customGreen)
                                .frame(maxWidth: .infinity)

                            Text("-")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.secondaryElement)

                            Text("\(result.missCount)")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.customRed)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    Divider()
                }
            }
            .padding(.vertical)
        }
        .background(Color.secondaryBackground)
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

// MARK: - Constants

private extension ResultListView {
    static let verticalSpacing: CGFloat = 8
}

// MARK: - Previews

struct ResultListView_Previews: PreviewProvider {
    static var previews: some View {
        ResultListView(results: PersistenceClient.mockDrill.results)
    }
}
