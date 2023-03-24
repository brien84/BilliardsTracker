//
//  MarqueeText.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-06-22.
//

import SwiftUI

struct MarqueeText: View {
    private let text: String
    private let font: UIFont

    @State private var isTextFitting = true
    @State private var offsetX: CGFloat = 0

    init(_ text: String, font: UIFont.TextStyle) {
        self.text = text
        self.font = UIFont.preferredFont(forTextStyle: font)
    }

    var body: some View {
        let textWidth = text.width(with: font)
        let textHeight = text.height(with: font)

        return GeometryReader { proxy in
            Text(text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: !isTextFitting, vertical: true)
                .offset(x: offsetX, y: 0)
                .font(Font(font))
                .onAppear {
                    isTextFitting = proxy.size.width > textWidth

                    if !isTextFitting {
                        let animation = Animation.easeInOut(duration: 3.0)
                                                 .delay(1.0)
                                                 .repeatForever(autoreverses: true)

                        withAnimation(animation) {
                            offsetX = proxy.size.width - textWidth
                        }
                    }
                }
        }
        .frame(height: textHeight)
    }
}

private extension String {
    func width(with font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes).width
    }

    func height(with font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes).height
    }
}

struct MarqueeText_Previews: PreviewProvider {
    static var previews: some View {
        MarqueeText("Lorem ipsum", font: .title2)
        MarqueeText("Lorem ipsum dolor sit amet, consectetur adipiscing elit", font: .title2)
    }
}
