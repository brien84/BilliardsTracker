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
}

final class DrillStore {
    let persistentContainer: NSPersistentContainer
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

    var didSaveContext = PassthroughSubject<Void, Never>()

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

    func getAllDrills() -> [Drill] {
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

        save()
    }

    func createResult(from context: ResultContext, in drill: Drill) {
        let result = DrillResult(context: persistentContainer.viewContext)
        result.potCount = context.potCount
        result.missCount = context.missCount
        result.date = context.date
        result.drill = drill

        save()
    }

    func delete(drill: Drill) {
        persistentContainer.viewContext.delete(drill)

        save()
    }

    func save() {
        do {
            try persistentContainer.viewContext.save()
            didSaveContext.send()
        } catch {
            print("\(type(of: self)) \(#function): \(error)")
            persistentContainer.viewContext.rollback()
        }
    }

    private func generatePreviewData() {
        for i in 1..<10 {
            let drill = Drill(context: persistentContainer.viewContext)
            drill.title = "Title \(i)"
            drill.attempts = i * 10
            drill.isFailable = Bool.random()

            for _ in 1...i {
                let result = DrillResult(context: persistentContainer.viewContext)
                result.potCount = Int.random(in: 0...drill.attempts)

                if drill.isFailable {
                    result.missCount = (drill.attempts - result.potCount > 0) ? 1 : 0
                } else {
                    result.missCount = drill.attempts - result.potCount
                }

                result.date = Date(timeIntervalSinceNow: Double.random(in: 3600...7200))
                result.drill = drill
            }
        }

        try! persistentContainer.viewContext.save()
    }
}
