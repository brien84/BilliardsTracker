//
//  GesturesView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-06-29.
//

import SwiftUI

private enum GesturesAnimation: Int {
    case potGesture
    case missGesture
    case bridgeHand

    var assetsPath: String {
        switch self {
        case .potGesture:
            return "Animations/PotGesture/"
        case .missGesture:
            return "Animations/MissGesture/"
        case .bridgeHand:
            return "Animations/BridgeHand/"
        }
    }

    var interval: TimeInterval {
        switch self {
        case .potGesture:
            return 0.025
        case .missGesture:
            return 0.02
        case .bridgeHand:
            return 1
        }
    }

    var subtitle: String {
        switch self {
        case .potGesture:
            return "Register a potted ball by flicking your wrist back and forth"
        case .missGesture:
            return "Register a missed ball by flicking your arm up and down"
        case .bridgeHand:
            return "For the best accuracy, wear the watch on your bridge hand"
        }
    }
}

struct GesturesView: View {
    @State private var currentTab: Int = 0

    var body: some View {
        TabView(selection: $currentTab) {
            GesturesAnimationView(animation: .potGesture)
                .tag(GesturesAnimation.potGesture)

            GesturesAnimationView(animation: .missGesture)
                .tag(GesturesAnimation.missGesture)

            GesturesAnimationView(animation: .bridgeHand)
                .tag(GesturesAnimation.bridgeHand)
        }
    }
}

private struct GesturesAnimationView: View {
    private let animation: GesturesAnimation
    private let images: [UIImage]
    private let isStatic: Bool
    @State private var isPaused = false

    init(animation: GesturesAnimation) {
        var images = [UIImage]()
        var index = 0

        while let image = UIImage(named: "\(animation.assetsPath)\(index)") {
            images.append(image)
            index += 1
        }

        self.animation = animation
        self.images = images
        self.isStatic = images.isEmpty
    }

    var body: some View {
        VStack {
            if !isStatic {
                TimelineView(.animation(minimumInterval: animation.interval, paused: isPaused)) { context in
                    AnimationView(date: context.date, images: images, isPaused: $isPaused)
                }
                .overlay {
                    Image("\(animation.assetsPath)overlay")
                        .resizable()
                        .frame(width: GesturesView.imageWidth, height: GesturesView.imageHeight)
                        .opacity(isPaused ? 1 : 0)
                }
            } else {
                Image("\(animation.assetsPath)overlay")
                    .resizable()
                    .frame(width: GesturesView.imageWidth, height: GesturesView.imageHeight)
            }

            Text(animation.subtitle)
                .font(.footnote)
                .foregroundColor(.primaryElement)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom)
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
            .frame(width: GesturesView.imageWidth, height: GesturesView.imageHeight)
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

// MARK: - Constants

private extension GesturesView {
    static let imageHeight: CGFloat = 96
    static let imageWidth: CGFloat = 96
}

// MARK: - Previews

struct GesturesView_Previews: PreviewProvider {
    static var previews: some View {
        GesturesView()
    }
}
