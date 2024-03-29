//
//  ResultContext.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-07.
//

import Foundation

struct ResultContext: Codable, Equatable {
    let potCount: Int
    let missCount: Int
    let date: Date
}
