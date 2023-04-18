//
//  Main+AlertState.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-18.
//

import ComposableArchitecture
import SwiftUI

extension Main {
    var initializationAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Something went terribly wrong!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
        }
    }

    var loadingAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Something went wrong!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Please restart BilliardsTracker. If the error persists reinstall the application.")
        }
    }

    var notReachableAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Watch app is not reachable!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Make sure BilliardsTracker Watch app is installed and running.")
        }
    }

    var notReadyAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Watch app is not in Tracked mode!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Make sure Tracked mode is selected in Watch app.")
        }
    }

    var savingAlert: AlertState<Main.Action> {
        AlertState {
            TextState("Something went wrong!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Latest changes will not be saved.")
        }
    }

    /// Updates alert color scheme and tint color to match the current user interface style.
    ///
    /// This function should be called whenever the user changes the appearance of the app.
    /// While `preferredColorScheme(_:)` `View` modifier sets the global app color scheme,
    /// it does not update the alert color scheme. Therefore, this function handles the process of setting
    /// the `overrideUserInterfaceStyle` property to ensure that the alert color scheme and
    /// tint color are updated correctly.
    func setAlertAppearance(_ appearance: Appearance) {
        switch appearance {
        case .light:
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = .light
        case .dark:
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = .dark
        case .system:
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = .unspecified
        }

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label
    }
}
