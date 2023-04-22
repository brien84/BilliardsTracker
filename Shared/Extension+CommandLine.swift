//
//  Extension+CommandLine.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-22.
//

extension CommandLine {
    static var isUITesting: Bool {
        Self.arguments.contains("ui-testing")
    }
}
