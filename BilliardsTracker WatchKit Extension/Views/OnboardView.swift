//
//  OnboardView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-06-29.
//

import SwiftUI

struct OnboardView: View {
    var body: some View {
        Text("Onboard")
    }
}

private enum AnimationAssets: String {
    case missGesture = "Animations/MissGesture/"
    case potGesture = "Animations/PotGesture/"
}

private struct OnboardAnimationView: View {
    @State private var shouldAnimate = false
    private let duration: TimeInterval
    private let startDelay: TimeInterval
    private let endDelay: TimeInterval
    private let subtitle: String

    private var images = [UIImage]()

    init(_ animation: AnimationAssets, duration: TimeInterval, startDelay: TimeInterval = 0.5, endDelay: TimeInterval = 2.0, subtitle: String) {
        self.duration = duration
        self.startDelay = startDelay
        self.endDelay = endDelay
        self.subtitle = subtitle
        self.images = getAnimationImages(from: animation.rawValue)
    }

    var body: some View {
        VStack {
            Color.clear
                .modifier(
                    ImageAnimation(shouldAnimate: shouldAnimate, images: images, completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + endDelay) {
                            shouldAnimate = false

                            withAnimation(Animation.linear(duration: duration).delay(startDelay)) {
                                shouldAnimate = true
                            }
                        }
                    })
                )

            Text(subtitle)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundColor(.primaryElement)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: duration).delay(startDelay)) {
                shouldAnimate = true
            }
        }
    }

    private func getAnimationImages(from assetsPath: String) -> [UIImage] {
        var images = [UIImage]()
        var index = 0

        while let image = UIImage(named: "\(assetsPath)\(index)") {
            images.append(image)
            index += 1
        }

        return images
    }
}

private struct ImageAnimation: AnimatableModifier {
    private let images: [UIImage]
    private var currentImageIndex = 0
    private let completion: () -> Void

    init(shouldAnimate: Bool, images: [UIImage], completion: @escaping () -> Void) {
        self.images = images
        self.completion = completion

        if shouldAnimate {
            currentImageIndex = images.indices.last ?? 0
        } else {
            currentImageIndex = 0
        }
    }

    var animatableData: CGFloat {
        get {
            CGFloat(currentImageIndex)
        }
        set {
            currentImageIndex = Int(newValue)
            notifyCompletionIfFinished()
        }
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if currentImageIndex >= 0 && currentImageIndex < images.count {
            Image(uiImage: images[currentImageIndex])
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Color.clear
        }
    }

    private func notifyCompletionIfFinished() {
        guard currentImageIndex == images.indices.last ?? 0 else { return }

        DispatchQueue.main.async {
            completion()
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}
