//
//  SectionLabelView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-16.
//

import SwiftUI

struct SectionLabelView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title.bold())
            .foregroundColor(.primaryElement)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top])
            .padding(.bottom, Self.bottomPadding)
    }
}

// MARK: - Constants

private extension SectionLabelView {
    static let bottomPadding: CGFloat = 8
}

// MARK: - Previews

struct SectionLabelView_Previews: PreviewProvider {
    static var previews: some View {
        SectionLabelView(title: "Preview")
    }
}
