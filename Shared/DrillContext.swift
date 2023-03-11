//
//  DrillContext.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-04.
//

import Foundation

struct DrillContext: Codable, Equatable {
    let isActive: Bool
    let attempts: Int
    let isContinuous: Bool
    let title: String
}
