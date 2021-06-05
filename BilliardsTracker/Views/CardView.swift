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
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .font(Font.title.weight(.bold))
                    .padding(.titlePadding)
                    .foregroundColor(.primaryElement)

                content
            }
        }
    }

    func setTitle(_ title: String) -> some View {
        var view = self
        view._title = State(initialValue: title)
        return view.id(UUID())
    }
}

private extension CGFloat {
    static var cornerRadius: CGFloat {
        50
    }

    static var titlePadding: CGFloat {
        32
    }
}

private struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

struct CardView_Previews: PreviewProvider {
    static var view: some View {
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

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
