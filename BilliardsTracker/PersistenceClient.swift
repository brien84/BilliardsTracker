//
//  PersistenceClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-01-24.
//

import ComposableArchitecture
import CoreData

enum PersistenceResponse: Equatable {
    case success
    case failure(Failure)

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
    var loadDrills: @Sendable () async throws -> [Drill]
}

extension PersistenceClient: DependencyKey {
    static var liveValue: Self {
        let store = PersistentStore()
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
                try await store.load()
            }
        )
    }
}

extension DependencyValues {
    var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}

private actor PersistentStore {
    private var persistentContainer: NSPersistentContainer?

    init() {
        let name = "BilliardsTrackerModel"

        guard
            let modelURL = Bundle.main.url(forResource: name, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            return
        }

        self.persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)

        var loadingError: Error?

        self.persistentContainer?.loadPersistentStores { _, error in
            loadingError = error
        }

        if loadingError != nil {
            self.persistentContainer = nil
        }
    }

    func load() throws -> [Drill] {
        guard let persistentContainer else { throw PersistenceResponse.Failure.initialization }

        let fetchRequest: NSFetchRequest<Drill> = Drill.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("\(Self.self).load: \(error)")
            throw PersistenceResponse.Failure.loading
        }
    }

    func create(drill: Drill) -> PersistenceResponse {
        guard let persistentContainer else { return PersistenceResponse.failure(.initialization) }

        let newDrill = Drill(context: persistentContainer.viewContext)
        newDrill.title = drill.title
        newDrill.attempts = drill.attempts
        newDrill.isFailable = drill.isFailable
        newDrill.dateCreated = Date()

        do {
            try newDrill.validateForInsert()
            try persistentContainer.viewContext.save()
            return PersistenceResponse.success
        } catch {
            print("\(Self.self).create: \(error)")
            persistentContainer.viewContext.rollback()
            return PersistenceResponse.failure(.saving)
        }
    }

    func delete(drill: Drill) -> PersistenceResponse {
        guard let persistentContainer else { return PersistenceResponse.failure(.initialization) }

        persistentContainer.viewContext.delete(drill)

        do {
            try persistentContainer.viewContext.save()
            return PersistenceResponse.success
        } catch {
            print("\(Self.self).delete: \(error)")
            persistentContainer.viewContext.rollback()
            return PersistenceResponse.failure(.saving)
        }
    }

    func insertResult(context: ResultContext, to drill: Drill) -> PersistenceResponse {
        guard let persistentContainer else { return PersistenceResponse.failure(.initialization) }

        let result = DrillResult(context: persistentContainer.viewContext)
        result.potCount = context.potCount
        result.missCount = context.missCount
        result.date = context.date
        result.drill = drill

        do {
            try result.validateForInsert()
            try persistentContainer.viewContext.save()
            return PersistenceResponse.success
        } catch {
            print("\(Self.self).insertResult: \(error)")
            persistentContainer.viewContext.rollback()
            return PersistenceResponse.failure(.saving)
        }
    }
}
