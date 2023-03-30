//
//  OnboardView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-06-29.
//

import SwiftUI

struct OnboardView: View {
    @State private var currentTab: Int = 0

    var body: some View {
        TabView(selection: $currentTab) {
            OnboardAnimationView(animation: .potGesture)
                .tag(0)

            OnboardAnimationView(animation: .missGesture)
                .tag(1)
        }
    }
}

private struct OnboardAnimationView: View {
    private let animation: OnboardAnimation
    private let images: [UIImage]

    @State private var isAnimating = false

    init(animation: OnboardAnimation) {
        self.animation = animation
        self.images = Self.getImages(for: animation)
    }

    var body: some View {
        VStack {
            ImageAnimationView(images: images, isAnimating: isAnimating) {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.endDelay) {
                    isAnimating = false
                    beginAnimating()
                }
            }

            Text(animation.subtitle)
                .font(.footnote)
                .foregroundColor(.primaryElement)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            beginAnimating()
        }
    }

    private func beginAnimating() {
        withAnimation(
            .linear(duration: animation.duration)
            .delay(Self.startDelay)
        ) {
            isAnimating = true
        }
    }

    private static func getImages(for animation: OnboardAnimation) -> [UIImage] {
        var images = [UIImage]()
        var index = 0

        while let image = UIImage(named: "\(animation.assetsPath)\(index)") {
            images.append(image)
            index += 1
        }

        return images
    }
}

private extension OnboardAnimationView {
    static let startDelay: TimeInterval = 0.5
    static let endDelay: TimeInterval = 2.0
}

private struct ImageAnimationView: Animatable, View {
    private var currentImageIndex = 0
    private let images: [UIImage]
    private let completion: () -> Void

    init(images: [UIImage], isAnimating: Bool, completion: @escaping () -> Void) {
        self.images = images
        self.completion = completion

        if isAnimating {
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
            guard newValue > 0 else { return }
            currentImageIndex = Int(newValue)
            notifyCompletionIfFinished()
        }
    }

    var body: some View {
        Image(uiImage: images[currentImageIndex])
            .resizable()
            .aspectRatio(contentMode: .fit)
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
