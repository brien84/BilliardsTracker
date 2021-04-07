//
//  ResultContext.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-07.
//

import Foundation

struct ResultContext: Codable, Identifiable {
    let id: UUID
    let potCount: Int
    let missCount: Int
}
