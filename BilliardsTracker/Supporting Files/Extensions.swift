//
//  Extensions.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-05-05.
//

import Foundation

extension Date {
    var asString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
