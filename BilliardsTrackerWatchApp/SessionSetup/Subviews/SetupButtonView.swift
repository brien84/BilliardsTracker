//
//  SetupButtonView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-09.
//

import SwiftUI

struct SetupButtonView: SessionSetupSubview {
    let action: () -> Void
    let imageName: String
    let title: String
    let subtitle: String
    var color: Color = .white

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Self.spacing) {
                Image(systemName: imageName)
                    .resizable()
                    .imageScale(.large)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Self.imageWidth, height: Self.imageHeight, alignment: .center)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(Color.primaryElement)

                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(Color.secondaryElement)
                }
            }
        }
        .foregroundStyle(color)
        .listItemTint(color.opacity(Self.tintOpacity))
    }
}

// MARK: - Constants

private extension SetupButtonView {
    static let imageHeight: CGFloat = 20
    static let imageWidth: CGFloat = 20
    static let spacing: CGFloat = 8
}

// MARK: - Previews

#Preview {
    List {
        SetupButtonView(
            action: { },
            imageName: "pencil",
            title: "Preview",
            subtitle: "Preview Subtitle"
        )
        .color(.orange)
    }
}
