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

    let animation: OnboardAnimation

    @State private var shouldAnimate = false

    var body: some View {
        VStack {
            ImageAnimationView(shouldAnimate: shouldAnimate, images: animation.images) {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.endDelay) {
                    shouldAnimate = false
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
            shouldAnimate = true
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

private extension OnboardAnimationView {
    static let startDelay: TimeInterval = 0.5
    static let endDelay: TimeInterval = 2.0
}

private struct ImageAnimationView: Animatable, View {
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
