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

extension DependencyValues {
    var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}

// swiftlint:disable force_try
extension PersistenceClient {
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
        let store = try! PersistentStore(inMemory: true)

        return Self(
            createDrill: { drill in
                await store.create(drill: drill)
            },
            deleteDrill: { drill in
                await store.delete(drill: drill)
            },
            insertResult: { context, drill in
                await store.insertResult(context: context, to: drill)
            },
            loadDrills: {
                await store.load()
            }
        )
    }

    static var previewDrill: Drill {
        _ = try! PersistentStore(inMemory: true)
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


extension PersistenceClient: DependencyKey {
    static var liveValue: Self {
        let store = try? PersistentStore()

        return Self(
            createDrill: { drill in
                guard let store else { return .didFail(.initialization) }
                return await store.create(drill: drill)
            },
            deleteDrill: { drill in
                guard let store else { return .didFail(.initialization) }
                return await store.delete(drill: drill)
            },
            insertResult: { context, drill in
                guard let store else { return .didFail(.initialization) }
                return await store.insertResult(context: context, to: drill)
            },
            loadDrills: {
                guard let store else { return .didFail(.initialization) }
                return await store.load()
            }
        )
    }
}

private actor PersistentStore {
    private static let name = "BilliardsTrackerModel"

    private static let model: NSManagedObjectModel? = {
        guard
            let modelURL = Bundle.main.url(forResource: PersistentStore.name, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            return nil
        }
        return model
    }()

    private let persistentContainer: NSPersistentContainer

    init(inMemory: Bool = false) throws {
        guard let model = PersistentStore.model else { throw PersistenceResponse.Failure.initialization }
        self.persistentContainer = NSPersistentContainer(name: PersistentStore.name, managedObjectModel: model)

        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        var loadPersistentStoresError: Error?

        self.persistentContainer.loadPersistentStores { _, error in
            loadPersistentStoresError = error
        }

        if let loadPersistentStoresError {
            throw loadPersistentStoresError
        }
    }

    func load() -> PersistenceResponse {
        let fetchRequest: NSFetchRequest<Drill> = Drill.fetchRequest()

        do {
            let drills = try persistentContainer.viewContext.fetch(fetchRequest)
            return .didLoad(drills)
        } catch {
            print("\(Self.self).load: \(error)")
            return .didFail(.loading)
        }
    }

    func create(drill: Drill) -> PersistenceResponse {
        let newDrill = Drill(context: persistentContainer.viewContext)
        newDrill.title = drill.title
        newDrill.isContinuous = drill.isContinuous
        newDrill.shotCount = drill.shotCount
        newDrill.dateCreated = .now

        do {
            try newDrill.validateForInsert()
            try persistentContainer.viewContext.save()
            return .didSucceed
        } catch {
            print("\(Self.self).create: \(error)")
            persistentContainer.viewContext.rollback()
            return .didFail(.saving)
        }
    }

    func delete(drill: Drill) -> PersistenceResponse {
        persistentContainer.viewContext.delete(drill)

        do {
            try persistentContainer.viewContext.save()
            return .didSucceed
        } catch {
            print("\(Self.self).delete: \(error)")
            persistentContainer.viewContext.rollback()
            return .didFail(.saving)
        }
    }

    func insertResult(context: ResultContext, to drill: Drill) -> PersistenceResponse {
        let result = DrillResult(context: persistentContainer.viewContext)
        result.potCount = context.potCount
        result.missCount = context.missCount
        result.date = context.date
        result.drill = drill

        do {
            try result.validateForInsert()
            try persistentContainer.viewContext.save()
            return .didSucceed
        } catch {
            print("\(Self.self).insertResult: \(error)")
            persistentContainer.viewContext.rollback()
            return .didFail(.saving)
        }
    }
}
