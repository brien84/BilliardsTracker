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

    var assetsPath: String {
        switch self {
        case .missGesture:
            return "Animations/MissGesture/"
        case .potGesture:
            return "Animations/PotGesture/"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .missGesture:
            return 1.1
        case .potGesture:
            return 1.5
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
