//
//  EmptyDrillListPrompt.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-05.
//

import SwiftUI

struct EmptyDrillListPrompt: View {
    let buttonAction: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .foregroundColor(.secondaryBackground)

            VStack {
                Image("paper")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Self.imageWidth, height: Self.imageHeight)
                    .padding(.bottom)
                    .shadow(color: .black, radius: Self.shadowRadius)

                VStack(spacing: Self.textVerticalSpacing) {
                    Text("Your Drills List Is Empty")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Start by adding a drill and begin tracking your training progress.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.primaryElement)

                FullWidthButtonView(text: "Add Drill") {
                    buttonAction()
                }
                .foregroundColor(.customBlue)
            }
            .padding()
        }
    }
}

// MARK: - Constants

private extension EmptyDrillListPrompt {
    static let cornerRadius: CGFloat = 16
    static let imageHeight: CGFloat = 100
    static let imageWidth: CGFloat = 100
    static let shadowRadius: CGFloat = 4
    static let textVerticalSpacing: CGFloat = 8
}

// MARK: - Previews

struct EmptyDrillListPrompt_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            EmptyDrillListPrompt(buttonAction: { })
                .padding()
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
