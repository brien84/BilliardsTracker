//
//  CardView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-05.
//

import SwiftUI

struct CardView<Content: View>: View {

    private let title: String
    private let infoMessage: String?
    private let content: Content

    @State private var showInfoMessage = false

    init(title: String, infoMessage: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.infoMessage = infoMessage
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.secondaryBackground)
                .modifier(CornerRadiusStyle(radius: Self.cornerRadius, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: .zero) {
                HStack {
                    Text(title)
                        .font(.title.weight(.bold))
                        .foregroundColor(.primaryElement)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Self.titlePadding)

                    if infoMessage != nil {
                        InfoMessageButton {
                            withAnimation {
                                showInfoMessage.toggle()
                            }
                        }
                    }
                }
                .overlay(
                    InfoMessageView(message: infoMessage)
                        .opacity(showInfoMessage ? 1 : 0)
                        .onTapGesture {
                            withAnimation {
                                showInfoMessage = false
                            }
                        }
                )

                content
            }
        }
    }
}

private struct InfoMessageButton: View {
    let action: () -> Void

    var body: some View {
        Button(
            action: {
                action()
            },
            label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.secondaryElement)
            }
        )
        .padding(.horizontal, Self.padding)
    }
}

private struct InfoMessageView: View {
    let message: String?

    var body: some View {
        Text(message ?? "")
            .font(.footnote)
            .foregroundColor(.primaryElement)
            .padding()
            .background(Color.primaryBackground)
            .cornerRadius(Self.cornerRadius)
            .padding()
    }
}

private struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

// MARK: - Constants

private extension CardView {
    static var cornerRadius: CGFloat {
        40
    }

    static var titlePadding: CGFloat {
        24
    }
}

private extension InfoMessageButton {
    static let padding: CGFloat = 24
}

private extension InfoMessageView {
    static let cornerRadius: CGFloat = 16
}

// MARK: - Previews

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            CardView(
                title: "Preview",
                infoMessage: "Some important information!"
            ) {
                Text("Some content")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.customRed)
            }
            .aspectRatio(0.8, contentMode: .fit)
        }
    }
}
