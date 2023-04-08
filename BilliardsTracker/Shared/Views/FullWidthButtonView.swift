//
//  FullWidthButtonView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-08.
//

import SwiftUI

struct FullWidthButtonView: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: Self.cornerRadius)

                Text(text)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.vertical)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Constants

private extension FullWidthButtonView {
    static let cornerRadius: CGFloat = 12
}

// MARK: - Previews

struct FullWidthButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            FullWidthButtonView(text: "Preview") { }
                .foregroundColor(.customBlue)
                .padding()
        }
    }
}
