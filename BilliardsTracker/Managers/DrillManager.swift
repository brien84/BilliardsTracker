//
//  DrillManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-04.
//

import Combine
import WatchConnectivity

enum RunState: Identifiable {
    var id: RunState { self }

    case running
    case stopped
    case loading
}

final class DrillManager: ObservableObject {
    private let connectivity = ConnectivityManager()
    @Published var connectivityError: ConnectivityError?

    private let store: DrillStore
    @Published var drills = [Drill]()

    var selectedDrill: Drill?
    var startDate = Date()

    @Published var runState: RunState = .stopped {
        didSet {
            if runState == .stopped {
                stop()
            }
        }
    }

    private var sortOption = SortOption.title {
        didSet {
            if sortOption != oldValue {
                drills = store.loadDrills(sortedBy: sortOption)
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    init(store: DrillStore) {
        self.store = store

        connectivity.didReceiveResultContext
            .receive(on: RunLoop.main)
            .sink { [unowned self] context in
                if let drill = self.selectedDrill {
                    self.addResult(context, to: drill)
                }
            }
            .store(in: &cancellables)

        store.didSaveContext
            .sink { [unowned self] result in
                switch result {
                case .success():
                    drills = store.loadDrills(sortedBy: sortOption)
                case .failure(_):
                    // TODO: Implement error handling!
                    print("ERROR!")
                }
            }
            .store(in: &cancellables)

        UserDefaults.standard.sortOptionPublisher
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

    func addResult(_ context: ResultContext, to drill: Drill) {
        store.addResult(from: context, to: drill)
    }

    func start(drill: Drill) {
        guard runState == .stopped else { return }

        runState = .loading

        startDate = Date()
        selectedDrill = drill

        let context = DrillContext(title: drill.title, attempts: drill.attempts, isFailable: drill.isFailable, isActive: true)

        connectivity.sendDrillContext(context)
            .receive(on: RunLoop.main)
            .subscribe(
                Subscribers.Sink(
                    receiveCompletion: { [weak self] completion in
                        if completion == .finished {
                            self?.runState = .running
                        }

                        if completion == .failure(.notReachable) {
                            self?.runState = .stopped
                            self?.connectivityError = .notReachable
                        }

                        if completion == .failure(.notReady) {
                            self?.runState = .stopped
                            self?.connectivityError = .notReady
                        }
                    },
                    receiveValue: { }
                )
        )
    }

    func stop() {
        selectedDrill = nil

        let context = DrillContext(title: "", attempts: 0, isFailable: false, isActive: false)
        _ = connectivity.sendDrillContext(context)
    }
}
