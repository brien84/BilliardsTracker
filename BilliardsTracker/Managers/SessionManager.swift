//
//  SessionManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-07-05.
//

import Combine
import Foundation

final class SessionManager: ObservableObject {
    private let store: DrillStore

    init(store: DrillStore, connectivity: WatchCommunication = ConnectivityManager()) {
        self.store = store
    }

    private func addResult(_ context: ResultContext, to drill: Drill) {
        store.addResult(from: context, to: drill)
    }
}
