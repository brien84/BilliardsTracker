//
//  EmptyDrillListPrompt.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-05.
//

import SwiftUI

struct EmptyDrillListPrompt: View {
    var buttonAction: () -> Void

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

                    Text("Begin by adding a drill and start tracking your training performance.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.primaryElement)

                Button {
                    buttonAction()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Self.buttonRadius)
                            .foregroundColor(.customBlue)

                        Text("Add Drill")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, Self.buttonPadding)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
    }
}

// MARK: - Constants

private extension EmptyDrillListPrompt {
    static let buttonRadius: CGFloat = 12
    static let buttonPadding: CGFloat = 15
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
