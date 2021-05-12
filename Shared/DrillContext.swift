//
//  DrillContext.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-04.
//

import Foundation

struct DrillContext: Codable {
    let title: String
    let attempts: Int
    let isFailable: Bool
    let isActive: Bool
}
