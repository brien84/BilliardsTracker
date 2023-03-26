//
//  LivePersistenceClient.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-03-26.
//

import Dependencies
import CoreData

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

actor PersistentStore {
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
