//
//  Extensions.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-05-05.
//

import SwiftUI

extension Binding where Value: Equatable {
    /// Workaround for `NavigationLink's `isActive = false` called multiple times per dismissal.
    public func removeDuplictates() -> Binding<Value> {
        var previous: Value? = nil

        return Binding<Value>(
            get: { self.wrappedValue },
            set: { newValue in
                guard newValue != previous else {
                    return
                }
                previous = newValue
                self.wrappedValue = newValue
            }
        )
    }
}


extension Date {
    var asString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
