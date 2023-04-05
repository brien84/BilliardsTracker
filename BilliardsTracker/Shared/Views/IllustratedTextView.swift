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
                .shadow(color: .black, radius: Self.shadowRadius)

            Text(text)
                .font(.title3.weight(.medium))
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
    static let shadowRadius: CGFloat = 8
}

// MARK: - Previews

struct IllustratedTextView_Previews: PreviewProvider {
    static var previews: some View {
        IllustratedTextView(imageName: "chalk", text: "This is preview!")
    }
}
