//
//  StoreManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-07-05.
//

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
                case .success():
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
        store.createDrill(title: title, attempts: attempts, isFailable: isFailable)
    }

    func delete(drill: Drill) {
        store.delete(drill: drill)
    }
}
