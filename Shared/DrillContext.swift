//
//  DrillContext.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-04.
//

import Foundation

struct DrillContext: Codable, Identifiable {
    var id: UUID
    var attempts: Int
    var potCount: Int
    var missCount: Int
}
