//
//  MenuButtonView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-05.
//

import SwiftUI

struct MenuButtonView: View {
    let imageName: String
    let title: String
    let subtitle: String
    let action: () -> Void
    var color: Color = .white

    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading) {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Self.imageWidth, height: Self.imageHeight, alignment: .leading)
                    .font(.title.weight(.thin))
                    .padding(.bottom)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.primaryElement)

                Text(subtitle)
                    .font(.caption2)
            }
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical)
        }
        .foregroundStyle(color)
        .listItemTint(color.opacity(Self.tintOpacity))
        .listRowInsets(Self.rowInsets)
    }
}

extension MenuButtonView {
    func setColor(_ color: Color) -> MenuButtonView {
        .init(
            imageName: self.imageName,
            title: self.title,
            subtitle: self.subtitle,
            color: color,
            action: self.action
        )
    }
}

private extension MenuButtonView {
    init(imageName: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.action = action
    }
}

// MARK: - Constants

private extension MenuButtonView {
    static let imageHeight: CGFloat = 40
    static let imageWidth: CGFloat = 40
    static let horizontalPadding: CGFloat = 16
    static let rowInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    static let tintOpacity: CGFloat = 0.15
}

// MARK: - Previews

#Preview {
    List {
        MenuButtonView(
            imageName: "magazine",
            title: "Preview",
            subtitle: "Preview subtitle",
            action: { }
        )
        .setColor(.customBlue)

        MenuButtonView(
            imageName: "pencil.and.ruler",
            title: "Preview",
            subtitle: "",
            action: { }
        )
        .setColor(.customRed)
    }
}
