//
//  CardView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-05.
//

import SwiftUI

struct CardView<Content: View>: View {
    private let content: Content

    @State private var title = ""
    @State private var infoMessage: String?
    @State private var showInfo = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .modifier(CornerRadiusStyle(radius: .cornerRadius, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
                .foregroundColor(.secondaryBackground)

            VStack(spacing: .zero) {
                HStack {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .font(Font.title.weight(.bold))
                        .padding(.titlePadding)
                        .foregroundColor(.primaryElement)

                    if infoMessage != nil {
                        infoButton
                    }
                }
                .overlay(
                    Group {
                        if showInfo {
                            infoOverlay
                        }
                    }
                )

                content
            }

        }
    }

    private var infoButton: some View {
        Button(
            action: {
                withAnimation {
                    showInfo.toggle()
                }
            },
            label: {
                Image(systemName: "info.circle")
                    .imageScale(.small)
                    .font(Font.title)
                    .foregroundColor(.secondaryElement)
            }
        )
        .padding(.horizontal, .titlePadding)
    }

    private var infoOverlay: some View {
        Group {
            if let infoMessage = infoMessage {
                Text(infoMessage)
                    .padding()
                    .background(Color.primaryBackground)
                    .font(.footnote)
                    .foregroundColor(.primaryElement)
                    .cornerRadius(.infoOverlayCornerRadius)
                    .padding()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showInfo.toggle()
                        }
                    }
            }
        }
    }

    func setTitle(_ title: String) -> CardView {
        var view = self
        view._title = State(initialValue: title)
        return view
    }

    func setInfo(_ message: String?) -> CardView {
        var view = self
        view._infoMessage = State(initialValue: message)
        return view
    }
}

private extension CGFloat {
    static var cornerRadius: CGFloat {
        50
    }

    static var titlePadding: CGFloat {
        32
    }

    static var infoOverlayCornerRadius: CGFloat {
        25
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

// MARK: - Previews

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            CardView {
                Text("Some content")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.customRed)
            }
            .setTitle("Preview")
            .aspectRatio(0.8, contentMode: .fit)
        }
    }
}
