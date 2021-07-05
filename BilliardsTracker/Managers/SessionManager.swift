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
    private let connectivity: WatchCommunication

    private(set) var selectedDrill: Drill?

    private var cancellables = Set<AnyCancellable>()

    init(store: DrillStore, connectivity: WatchCommunication = ConnectivityManager()) {
        self.store = store
        self.connectivity = connectivity

        connectivity.didReceiveResultContext
            .receive(on: RunLoop.main)
            .sink { [unowned self] context in
                if let drill = self.selectedDrill {
                    self.addResult(context, to: drill)
                }
            }
            .store(in: &cancellables)
    }

    private func addResult(_ context: ResultContext, to drill: Drill) {
        store.addResult(from: context, to: drill)
    }
}
