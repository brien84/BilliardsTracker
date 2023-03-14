//
//  Extensions.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-05-05.
//

import SwiftUI

/// Dinamically hides and disables view.
///
/// Since iOS15 the behaviour of `XCUIElement` `isHittable` property
/// has changed in a way that it no longer returns true if `View` opacity is zero.
/// As a workaround this function hides and also disables the `View`
/// therefore we can now assert on `XCUIElement` `isEnabled` property.
extension View {
    func hidden(_ hidden: Bool) -> some View {
        opacity(hidden ? 0 : 1).disabled(hidden)
    }
}
