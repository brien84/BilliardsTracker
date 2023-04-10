//
//  OnboardView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-06-29.
//

import SwiftUI

private enum OnboardAnimation {
    case missGesture
    case potGesture

    var assetsPath: String {
        switch self {
        case .missGesture:
            return "Animations/MissGesture/"
        case .potGesture:
            return "Animations/PotGesture/"
        }
    }

    var interval: TimeInterval {
        switch self {
        case .missGesture:
            return 0.02
        case .potGesture:
            return 0.025
        }
    }

    var subtitle: String {
        switch self {
        case .missGesture:
            return "Flick your arm up and down to register missed ball"
        case .potGesture:
            return "Flick your wrist back and forth to register potted ball"
        }
    }
}

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

    @State private var isPaused = false

    init(animation: OnboardAnimation) {
        var images = [UIImage]()
        var index = 0

        while let image = UIImage(named: "\(animation.assetsPath)\(index)") {
            images.append(image)
            index += 1
        }

        self.animation = animation
        self.images = images
    }

    var body: some View {
        VStack {
            TimelineView(.animation(minimumInterval: animation.interval, paused: isPaused)) { context in
                AnimationView(date: context.date, images: images, isPaused: $isPaused)
            }
            .overlay {
                Image("\(animation.assetsPath)overlay")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(isPaused ? 1 : 0)
            }

            Text(animation.subtitle)
                .font(.footnote)
                .foregroundColor(.primaryElement)
                .multilineTextAlignment(.center)
        }
        .onChange(of: isPaused) { isPaused in
            if isPaused {
                Task {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    self.isPaused = false
                }
            }
        }
    }
}

private struct AnimationView: View {
    let date: Date
    let images: [UIImage]

    @Binding var isPaused: Bool
    @State private var currentIndex = 0
    @State private var cycleCount = 0
    @State private var isReversing = false

    var body: some View {
        Image(uiImage: images[currentIndex])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onChange(of: date) { _ in
                if currentIndex == 0 {
                    if isReversing {
                        isReversing = false
                        cycleCount += 1

                        if cycleCount == 2 {
                            isPaused = true
                            cycleCount = 0
                            return
                        }
                    }
                }

                if currentIndex == images.count - 1 {
                    isReversing = true
                }

                currentIndex += isReversing ? -1 : 1
            }
    }
}

// MARK: - Previews

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}
