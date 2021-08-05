//
//  SettingsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-13.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsManager()

    @Binding var isShowingSettings: Bool

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: .zero) {
                ZStack {
                    Color.primaryBackground
                        .edgesIgnoringSafeArea(.bottom)

                    VStack(alignment: .leading, spacing: .zero) {
                        SettingsSection(title: "sort by") {
                            ForEach(SortOption.allCases) { option in
                                SettingsCell {
                                    HStack {
                                        SettingsCellLabel(title: option.title, imageName: option.imageName)
                                            .accessibility(identifier: "settingsView_\(option.title.lowercased())Text")

                                        Spacer()

                                        SettingsCellCheckmark()
                                            .opacity(settings.sortOption == option ? 1 : 0)
                                            .accessibility(identifier: "settingsView_\(option.title.lowercased())Image")
                                    }
                                }
                                .onTapGesture {
                                    settings.sortOption = option
                                }
                            }
                        }

                        Spacer()
                    }
                }
                .frame(width: proxy.size.width * .widthModifier)

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isShowingSettings = false
                        }
                    }
            }
        }
    }
}

private struct SettingsSection<Content: View>: View {
    private let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .sectionSpacing) {
            Text(title.uppercased())
                .padding(.horizontal)
                .padding(.top, .sectionTopPadding)
                .font(Font.footnote)
                .foregroundColor(.secondaryElement)

            content
        }
    }
}

private struct SettingsCell<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(height: .cellHeight)
            .frame(maxWidth: .infinity)
            .padding(.cellPadding)
            .background(Color.secondaryBackground)
            .cornerRadius(.cellCornerRadius)
            .padding(.horizontal)
    }
}

private struct SettingsCellLabel: View {
    var title: String
    var imageName: String

    var body: some View {
        Label {
            Text(title)
                .foregroundColor(.primaryElement)
        } icon: {
            Image(systemName: imageName)
                .frame(width: .cellLabelHeight)
                .foregroundColor(.secondaryElement)
        }
    }
}

private struct SettingsCellCheckmark: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(Font.body.weight(.bold))
            .foregroundColor(.customBlue)
    }
}

private extension CGFloat {
    static var widthModifier: CGFloat {
        0.75
    }

    static var sectionSpacing: CGFloat {
        8
    }

    static var sectionTopPadding: CGFloat {
        16
    }

    static var cellHeight: CGFloat {
        25
    }

    static var cellPadding: CGFloat {
        16
    }

    static var cellCornerRadius: CGFloat {
        15
    }

    static var cellLabelHeight: CGFloat {
        25
    }
}

private extension SortOption {
    var title: String {
        switch self {
        case .attempts:
            return "Attempts"
        case .dateCreated:
            return "Date created"
        case .title:
            return "Title"
        }
    }

    var imageName: String {
        switch self {
        case .attempts:
            return "repeat"
        case .dateCreated:
            return "calendar"
        case .title:
            return "textformat"
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var view: some View {
        ZStack {
            Color.secondaryBackground
                .ignoresSafeArea()

            SettingsView(isShowingSettings: .constant(true))
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
