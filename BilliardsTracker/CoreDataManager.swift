//
//  CoreDataManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-06.
//

import Combine
import CoreData

final class CoreDataManager {
    private let persistentContainer: NSPersistentContainer

    var didSaveContext = PassthroughSubject<Void, Never>()

    init() {
        persistentContainer = NSPersistentContainer(name: "BilliardsTrackerModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("\(type(of: self)) \(#function): \(error.localizedDescription)")
            }
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
        drill.attempts = Int16(attempts)

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
