//
//  StoreManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-07-05.
//

import ComposableArchitecture
import CoreData

struct PersistentStoreClient {
    var create: @Sendable (Drill) async -> Void
    var delete: @Sendable (Drill) async -> Void
    var insertResult: @Sendable (ResultContext, Drill) async -> Void
    var load: @Sendable () async -> [Drill]
}

extension DependencyValues {
    var persistentStore: PersistentStoreClient {
        get { self[PersistentStoreClient.self] }
        set { self[PersistentStoreClient.self] = newValue }
    }
}

extension PersistentStoreClient: DependencyKey {
    static var liveValue: Self {
        let xxx = XXX()
        return Self(
            create: { drill in
                await xxx.createDrill(title: drill.title, attempts: drill.attempts, isFailable: drill.isFailable)
            },
            delete: { drill in
                await xxx.delete(drill: drill)
            },
            insertResult: { resultContext, drill in
                await xxx.addResult(from: resultContext, to: drill)
            },
            load: {
                await xxx.load()
            }
        )
    }
}

actor XXX {
    private let persistentContainer: NSPersistentContainer

    init() {
        let name = "BilliardsTrackerModel"
        let modelURL = Bundle.main.url(forResource: name, withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        self.persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)
        self.persistentContainer.loadPersistentStores { _, _ in }
        print("BRUH")
    }

    // swiftlint:disable force_try
    func load() -> [Drill] {
        print("KOO KOO")
        let fetchRequest: NSFetchRequest<Drill> = Drill.fetchRequest()
        return try! persistentContainer.viewContext.fetch(fetchRequest)
    }

    func delete(drill: Drill) {
        persistentContainer.viewContext.delete(drill)

        save()
    }

    func createDrill(title: String, attempts: Int, isFailable: Bool) {
        let drill = Drill(context: persistentContainer.viewContext)
        drill.title = title
        drill.attempts = attempts
        drill.isFailable = isFailable
        drill.dateCreated = Date()

//        do {
            try! drill.validateForInsert()
//        } catch {
//            print("\(type(of: self)) \(#function): \(error.localizedDescription)")
//            persistentContainer.viewContext.rollback()
//            didSaveContext.send(.failure(.saving))
//            return
//        }

        save()
    }

    func addResult(from context: ResultContext, to drill: Drill) {
        let result = DrillResult(context: persistentContainer.viewContext)
        result.potCount = context.potCount
        result.missCount = context.missCount
        result.date = context.date
        result.drill = drill

//        do {
            try! result.validateForInsert()
//        } catch {
//            print("\(type(of: self)) \(#function): \(error.localizedDescription)")
//            persistentContainer.viewContext.rollback()
//            didSaveContext.send(.failure(.saving))
//            return
//        }

        save()
    }

    private func save() {
        try! persistentContainer.viewContext.save()
    }

    deinit {
        print("BYE!")
    }

}

//struct MovieClient {
//    var fetch: () -> Effect<[Movie], MovieClient.Error>
//}
//
//extension DependencyValues {
//    var movieClient: MovieClient {
//        get { self[MovieClient.self] }
//        set { self[MovieClient.self] = newValue }
//    }
//}
//
//extension MovieClient: DependencyKey {
//    static let liveValue = Self(
//        fetch: {
//
//        }
//    )
//
//    static let previewValue = Self(
//        fetch: {
//            Effect(value: Array(repeating: Movie(showings: [Showing()]), count: 5))
//        }
//    )
//
//    static let testValue = Self(
//        fetch: unimplemented("\(Self.self).fetch")
//    )
//}

import Combine
import Foundation

final class StoreManager: ObservableObject {
    private let store: DrillStore
    @Published var savingError: DrillStoreError?

    @Published var drills = [Drill]()

    private var sortOption = SortOption.title {
        didSet {
            if sortOption != oldValue {
                drills = store.loadDrills(sortedBy: sortOption)
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    init(store: DrillStore, userDefaults: UserDefaults = .standard) {
        self.store = store

        store.didSaveContext
            .sink { [unowned self] result in
                switch result {
                case .success:
                    drills = store.loadDrills(sortedBy: sortOption)
                case .failure(let error):
                    if error == .saving {
                        savingError = error
                    }
                }
            }
            .store(in: &cancellables)

        userDefaults.sortOptionPublisher
            .sink { [unowned self] option in
                sortOption = option
            }
            .store(in: &cancellables)

        drills = store.loadDrills(sortedBy: sortOption)
    }

    func addDrill(title: String, attempts: Int, isFailable: Bool) {
        // store.createDrill(title: title, attempts: attempts, isFailable: isFailable)

        DispatchQueue.main.async {
            self.savingError = DrillStoreError.saving
        }

    }

    func delete(drill: Drill) {
        store.delete(drill: drill)
    }
}
