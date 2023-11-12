//
//  ListButtonView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-05.
//

import SwiftUI

struct ListButtonView: View {
    var color: Color = .white
    var imageName: String = ""
    var subtitle: String = ""
    let title: String
    let action: () -> Void
    let secondaryAction: () -> Void

    init(
        title: String,
        action: @escaping () -> Void,
        secondaryAction: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
        self.secondaryAction = secondaryAction
    }

    var body: some View {
        ZStack(alignment: .top) {
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
                        .opacity(subtitle.isEmpty ? 0 : 1)
                        .lineLimit(1)
                        .minimumScaleFactor(Self.scaleFactor)
                }
                .padding(.horizontal, Self.horizontalPadding)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color.opacity(Self.tintOpacity))
                .foregroundStyle(color)
                .cornerRadius(Self.cornerRadius)
            }
            .buttonStyle(.plain)

            SecondaryActionButton {
                secondaryAction()
            }
            .foregroundStyle(color, Color.black)
        }
        .listItemTint(.clear)
        .listRowInsets(Self.rowInsets)
    }
}

private struct SecondaryActionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Self.imageWidth, height: Self.imageHeight, alignment: .trailing)
                .padding([.bottom, .horizontal], Self.padding)
                .padding(.top)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

extension ListButtonView {
    func color(_ color: Color) -> ListButtonView {
        .init(
            color: color,
            imageName: self.imageName,
            subtitle: self.subtitle,
            title: self.title,
            action: self.action,
            secondaryAction: self.secondaryAction
        )
    }

    func imageName(_ imageName: String) -> ListButtonView {
        .init(
            color: self.color,
            imageName: imageName,
            subtitle: self.subtitle,
            title: self.title,
            action: self.action,
            secondaryAction: self.secondaryAction
        )
    }

    func subtitle(_ subtitle: String) -> ListButtonView {
        .init(
            color: self.color,
            imageName: self.imageName,
            subtitle: subtitle,
            title: self.title,
            action: self.action,
            secondaryAction: self.secondaryAction
        )
    }
}

private extension ListButtonView {
    init(
        color: Color,
        imageName: String,
        subtitle: String,
        title: String,
        action: @escaping () -> Void,
        secondaryAction: @escaping () -> Void
    ) {
        self.color = color
        self.imageName = imageName
        self.subtitle = subtitle
        self.title = title
        self.action = action
        self.secondaryAction = secondaryAction
    }
}

// MARK: - Constants

private extension ListButtonView {
    static let cornerRadius: CGFloat = 15
    static let imageHeight: CGFloat = 48
    static let imageWidth: CGFloat = 48
    static let horizontalPadding: CGFloat = 16
    static let rowInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    static let scaleFactor: CGFloat = 0.7
    static let tintOpacity: CGFloat = 0.15
}

private extension SecondaryActionButton {
    static let imageHeight: CGFloat = 28
    static let imageWidth: CGFloat = 28
    static let padding: CGFloat = 16
}

// MARK: - Previews

#Preview {
    List {
        ListButtonView(
            title: "Preview",
            action: { },
            secondaryAction: { }
        )
        .color(.customBlue)
        .imageName("magazine")
        .subtitle("Preview subtitle.")

        ListButtonView(
            title: "Preview",
            action: { },
            secondaryAction: { }
        )
    }
}
