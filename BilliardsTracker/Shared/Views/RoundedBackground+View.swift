//
//  RoundedBackground+View.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-17.
//

import SwiftUI

private struct RoundedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
            .padding(.horizontal)
    }
}

extension View {
    func roundedBackground() -> some View {
        modifier(RoundedBackground())
    }
}

// MARK: - Constants

private extension RoundedBackground {
    static let cornerRadius: CGFloat = 16
}

// MARK: - Previews

struct RoundedBackground_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.green
                .ignoresSafeArea()

            Text("Preview")
                .font(.largeTitle)
                .foregroundColor(.primaryElement)
                .padding()
                .roundedBackground()
        }
    }
}
