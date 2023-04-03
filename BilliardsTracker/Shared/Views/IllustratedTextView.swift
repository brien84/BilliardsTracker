//
//  IllustratedTextView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-03.
//

import SwiftUI

struct IllustratedTextView: View {
    let imageName: String
    let text: String

    var body: some View {
        VStack(spacing: Self.verticalSpacing) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Self.width, height: Self.height)

            Text(text)
                .font(.headline)
                .foregroundColor(.primaryElement)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

private extension IllustratedTextView {
    static let verticalSpacing: CGFloat = 16
    static let width: CGFloat = 100
    static let height: CGFloat = 100
}
