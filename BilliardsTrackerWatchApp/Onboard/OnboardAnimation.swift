//
//  OnboardAnimation.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-03-25.
//

import SwiftUI

enum OnboardAnimation {
    case missGesture
    case potGesture

    var duration: TimeInterval {
        switch self {
        case .missGesture:
            return 1.1
        case .potGesture:
            return 1.5
        }
    }

    var images: [UIImage] {
        switch self {
        case .missGesture:
            return getImages(for: self)
        case .potGesture:
            return getImages(for: self)
        }
    }

    var subtitle: String {
        switch self {
        case .missGesture:
            return "Flick your wrist back and forth to register potted ball"
        case .potGesture:
            return "Flick your arm up and down to register missed ball"
        }
    }

    private var path: String {
        switch self {
        case .missGesture:
            return "Animations/MissGesture/"
        case .potGesture:
            return "Animations/PotGesture/"
        }
    }

    private func getImages(for animation: OnboardAnimation) -> [UIImage] {
        var images = [UIImage]()
        var index = 0

        while let image = UIImage(named: "\(animation.path)\(index)") {
            images.append(image)
            index += 1
        }

        return images
    }
}
