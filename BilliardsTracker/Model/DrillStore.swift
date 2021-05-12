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
            generateDummyData()
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

    private func generateDummyData() {
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
