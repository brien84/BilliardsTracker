//
//  MarqueeText.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-06-22.
//

import SwiftUI

struct MarqueeText: View {

    private let text: String

    @State private var offsetX: CGFloat = 0
    @State private var textFrame: CGRect = CGRect()

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        GeometryReader { proxy in
            Text(text)
                .background(FrameGetter(frame: $textFrame))
                .lineLimit(1)
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(x: offsetX, y: .zero)
                .onChange(of: textFrame) { _ in
                    guard textFrame.width > proxy.size.width else { return }
                    let duration = textFrame.width / proxy.size.width * 1.25

                    withAnimation(
                        .easeInOut(duration: duration).delay(1.0).repeatForever()
                    ) {
                        offsetX = proxy.size.width - textFrame.width
                    }
                }
        }
        .frame(height: textFrame.height)
    }
}

struct MarqueeText_Previews: PreviewProvider {
    static var previews: some View {
        MarqueeText("Lorem ipsum")
            .font(.title2)
        MarqueeText("Lorem ipsum dolor sit amet, consectetur adipiscing elit")
            .font(.title2)
    }
}

/// Reads and writes the `frame` of a `View` into a binding.
///
/// To use `FrameGetter`, add it to a `View` as a background using the `background` modifier.
/// The `frame` of the surrounding view will be read and stored in the provided property.
///
/// Example:
///
///     struct SomeView: View {
///         @State var frame: CGRect = CGRect()
///
///         var body: some View {
///             VStack {
///                 Text("Hello, World!")
///             }
///             .background(FrameGetter(frame: $frame))
///         }
///     }
private struct FrameGetter: View {
    @Binding var frame: CGRect

    var body: some View {
        GeometryReader { proxy in
            self.makeView(proxy: proxy)
        }
    }

    func makeView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            frame = proxy.frame(in: .global)
        }

        return Color.clear
    }
}
