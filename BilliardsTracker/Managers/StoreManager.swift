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

    @Published var drills = [Drill]()

    init(store: DrillStore) {
        self.store = store

        drills = store.loadDrills()
    }

    func addDrill(title: String, attempts: Int, isFailable: Bool) {
        store.createDrill(title: title, attempts: attempts, isFailable: isFailable)
    }
}
