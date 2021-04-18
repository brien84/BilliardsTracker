//
//  DrillStore.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-06.
//

import Combine
import CoreData

final class DrillStore {
    private let persistentContainer: NSPersistentContainer

    var didSaveContext = PassthroughSubject<Void, Never>()

    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "BilliardsTrackerModel")

        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("\(type(of: self)) \(#function): \(error.localizedDescription)")
            }
        }

        if inMemory {
            for i in 1..<10 {
                let drill = Drill(context: persistentContainer.viewContext)
                drill.title = "Title \(i)"
                drill.attempts = i
            }

            try! persistentContainer.viewContext.save()
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

    func createDrill(title: String, attempts: Int) {
        let drill = Drill(context: persistentContainer.viewContext)
        drill.title = title
        drill.attempts = attempts

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

}
