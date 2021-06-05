//
//  DrillStore.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-06.
//

import Combine
import CoreData

enum DrillStoreError: Error {
    case initialization
    case saving
}

final class DrillStore {
    var didSaveContext = PassthroughSubject<Result<Void, DrillStoreError>, Never>()

    private let persistentContainer: NSPersistentContainer
    private static var model: NSManagedObjectModel?

    private static func loadModel(name: String) throws -> NSManagedObjectModel {
        if model == nil {
            guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
                print("Could not find `\(name)` url.")
                throw DrillStoreError.initialization
            }

            guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
                print("Could not initialize `\(name)`.")
                throw DrillStoreError.initialization
            }

            self.model = model
        }

        return model!
    }

    private static func loadContainer(name: String) throws -> NSPersistentContainer {
        NSPersistentContainer(name: name, managedObjectModel: try loadModel(name: name))
    }

    init(inMemory: Bool = false, isPreview: Bool = false) throws {
        persistentContainer = try DrillStore.loadContainer(name: "BilliardsTrackerModel")

        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        var loadPersistentStoresError: Error?

        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                loadPersistentStoresError = error
            }
        }

        if let error = loadPersistentStoresError {
            print("\(type(of: self)) \(#function): \(error.localizedDescription)")
            throw DrillStoreError.initialization
        }

        if inMemory && isPreview {
            generatePreviewData()
        }
    }

    func loadDrills() -> [Drill] {
        let fetchRequest: NSFetchRequest<Drill> = Drill.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("\(type(of: self)) \(#function): \(error.localizedDescription)")
            return []
        }
    }

    func createDrill(title: String, attempts: Int, isFailable: Bool) {
        let drill = Drill(context: persistentContainer.viewContext)
        drill.title = title
        drill.attempts = attempts
        drill.isFailable = isFailable

        do {
            try drill.validateForInsert()
        } catch {
            print("\(type(of: self)) \(#function): \(error.localizedDescription)")
            persistentContainer.viewContext.rollback()
            didSaveContext.send(.failure(.saving))
            return
        }

        save()
    }

    func addResult(from context: ResultContext, to drill: Drill) {
        let result = DrillResult(context: persistentContainer.viewContext)
        result.potCount = context.potCount
        result.missCount = context.missCount
        result.date = context.date
        result.drill = drill

        do {
            try result.validateForInsert()
        } catch {
            print("\(type(of: self)) \(#function): \(error.localizedDescription)")
            persistentContainer.viewContext.rollback()
            didSaveContext.send(.failure(.saving))
            return
        }

        save()
    }

    func delete(drill: Drill) {
        persistentContainer.viewContext.delete(drill)

        save()
    }

    private func save() {
        do {
            try persistentContainer.viewContext.save()
            didSaveContext.send(.success(()))
        } catch {
            print("\(type(of: self)) \(#function): \(error)")
            persistentContainer.viewContext.rollback()
            didSaveContext.send(.failure(.saving))
        }
    }

    private func generatePreviewData() {
        for i in 2...10 {
            let drill = Drill(context: persistentContainer.viewContext)
            drill.title = "Title \(i)"
            drill.attempts = i * 10
            drill.isFailable = i % 2 == 0

            for _ in 1...i {
                let result = DrillResult(context: persistentContainer.viewContext)

                if drill.isFailable {
                    result.missCount = Int.random(in: 0...1)
                    result.potCount = result.missCount == 0 ? drill.attempts : Int.random(in: 0..<drill.attempts)
                } else {
                    result.missCount = Int.random(in: 0...drill.attempts)
                    result.potCount = drill.attempts - result.missCount
                }

                result.date = Date(timeIntervalSinceNow: Double.random(in: 3600...7200))
                result.drill = drill
            }
        }

        try! persistentContainer.viewContext.save()
    }
}
