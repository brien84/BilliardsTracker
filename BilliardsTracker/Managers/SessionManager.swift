//
//  SessionManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-07-05.
//

import Combine
import Foundation

enum SessionState: Identifiable {
    var id: SessionState { self }

    case running
    case stopped
    case loading
}

final class SessionManager: ObservableObject {
    private let connectivity: WatchCommunication
    @Published var connectivityError: ConnectivityError?

    private(set) var selectedDrill: Drill?
    private(set) var startDate = Date()

    @Published var drill: Drill?
    @Published var result: ResultContext?

    @Published var runState: SessionState = .stopped {
        didSet {
            if runState == .stopped {
                stop()
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    init(connectivity: WatchCommunication = ConnectivityManager()) {
        self.connectivity = connectivity

        connectivity.didReceiveResultContext
            .receive(on: RunLoop.main)
            .sink { [unowned self] context in
                if let drill = self.selectedDrill {
                    self.drill = drill
                    self.result = context
                }
            }
            .store(in: &cancellables)
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
