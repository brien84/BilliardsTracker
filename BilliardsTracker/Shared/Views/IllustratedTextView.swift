//
//  IllustratedTextView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-03.
//

import SwiftUI

struct IllustratedTextView: View {
    let imageName: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Self.width, height: Self.height)
                .shadow(color: .black, radius: Self.shadowRadius)

            VStack(spacing: Self.textSpacing) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primaryElement)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.body.weight(.light))
                    .foregroundColor(.secondaryElement)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

private extension IllustratedTextView {
    static let verticalSpacing: CGFloat = 16
    static let textSpacing: CGFloat = 4
    static let width: CGFloat = 100
    static let height: CGFloat = 100
    static let shadowRadius: CGFloat = 8
}

// MARK: - Previews

struct IllustratedTextView_Previews: PreviewProvider {
    static var previews: some View {
        IllustratedTextView(
            imageName: "chalk",
            title: "Preview title",
            subtitle: "This is preview subtitle!"
        )
    }
}
