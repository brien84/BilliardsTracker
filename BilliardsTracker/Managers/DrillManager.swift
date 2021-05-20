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

    private var cancellables = Set<AnyCancellable>()

    init(store: DrillStore = DrillStore()) {
        self.store = store

        connectivity.didReceiveResultContext
            .receive(on: RunLoop.main)
            .sink { [weak self] context in
                if let drill = self?.selectedDrill {
                    self?.addResult(context, to: drill)
                }
            }
            .store(in: &cancellables)

        store.didSaveContext
            .sink { [weak self] in
                self?.drills = self?.store.getAllDrills() ?? []
            }
            .store(in: &cancellables)

        drills = store.getAllDrills()
    }

    func addDrill(title: String, attempts: Int, isFailable: Bool) {
        store.createDrill(title: title, attempts: attempts, isFailable: isFailable)
    }

    func delete(drill: Drill) {
        store.delete(drill: drill)
    }

    func addResult(_ context: ResultContext, to drill: Drill) {
        store.createResult(from: context, in: drill)
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
