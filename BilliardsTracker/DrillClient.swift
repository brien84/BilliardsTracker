//
//  DrillClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture
import CoreData

struct DrillClient {
    var create: @Sendable (String, Int, Bool) async throws -> Void
    var delete: @Sendable (Drill) async throws -> Void
    var insertResult: @Sendable (ResultContext, Drill) async throws -> Void
    var load: @Sendable () async throws -> [Drill]
}

extension DrillClient: DependencyKey {
    static var liveValue: Self {
        return Self(
            create: { _, _, _ in

            },
            delete: { _ in

            },
            insertResult: { _, _ in

            },
            load: {
                []
            }
        )
    }
}

extension DependencyValues {
    var drillClient: DrillClient {
        get { self[DrillClient.self] }
        set { self[DrillClient.self] = newValue }
    }
}
