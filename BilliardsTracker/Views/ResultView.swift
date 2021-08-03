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
            RoundedRectangle(cornerRadius: .cornerRadius)
                .foregroundColor(.secondaryBackground)

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
    }
}

private extension CGFloat {
    static var cornerRadius: CGFloat {
        15
    }
}

// swiftlint:disable force_try
struct ResultView_Previews: PreviewProvider {
    static var store = try! DrillStore(inMemory: true, isPreview: true)
    static var result = store.loadDrills().first!.results.first!

    static var view: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ResultView(result: result)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
