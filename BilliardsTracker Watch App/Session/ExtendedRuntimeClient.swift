//
//  ExtendedRuntimeClient.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-15.
//

import ComposableArchitecture

struct ExtendedRuntimeClient {
    var start: @Sendable () async -> Void
    var stop: @Sendable () async -> Void
}
