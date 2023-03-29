//
//  PersistenceClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture
import CoreData

enum PersistenceResponse: Equatable {
    case didSucceed
    case didLoad([Drill])
    case didFail(Failure)

    enum Failure: Error {
        case initialization
        case loading
        case saving
    }
}

struct PersistenceClient {
    var createDrill: @Sendable (Drill) async -> PersistenceResponse
    var deleteDrill: @Sendable (Drill) async -> PersistenceResponse
    var insertResult: @Sendable (ResultContext, Drill) async -> PersistenceResponse
    var loadDrills: @Sendable () async -> PersistenceResponse
}

extension PersistenceClient: TestDependencyKey {
    static let testValue = Self(
        createDrill: { _ in
            unimplemented("\(Self.self).createDrill")
        },
        deleteDrill: { _ in
            unimplemented("\(Self.self).deleteDrill")
        },
        insertResult: { _, _ in
            unimplemented("\(Self.self).insertResult")
        },
        loadDrills: {
            unimplemented("\(Self.self).loadDrills")
        }
    )

    static var previewValue: Self {
        let store = try? PersistentStore(inMemory: true)

        return Self(
            createDrill: { drill in
                await store!.create(drill: drill)
            },
            deleteDrill: { drill in
                await store!.delete(drill: drill)
            },
            insertResult: { context, drill in
                await store!.insertResult(context: context, to: drill)
            },
            loadDrills: {
                await store!.load()
            }
        )
    }

    static var mockDrill: Drill {
        _ = try? PersistentStore(inMemory: true)
        let drill = Drill(entity: Drill().entity, insertInto: nil)
        let i = Int.random(in: 1...100)
        drill.title = "Preview Drill \(i)"
        drill.shotCount = i
        drill.isContinuous = Bool.random()

        for _ in 1..<Int.random(in: 5...10) {
            let result = DrillResult(entity: DrillResult.entity(), insertInto: nil)
            result.potCount = Int.random(in: 0...drill.shotCount)
            result.missCount = drill.shotCount - result.potCount
            result.date = Date(timeIntervalSinceNow: 3600)
            result.drill = drill
            drill.addToResultsValue(result)
        }

        return drill
    }
}

extension DependencyValues {
    var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}
