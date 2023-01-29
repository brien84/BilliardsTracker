//
//  SessionManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-07-05.
//

import ComposableArchitecture
import Foundation

enum SessionState: Identifiable {
    var id: SessionState { self }

    case running
    case stopped
    case loading
}

final class SessionManager: ObservableObject {
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

    @Dependency(\.connectivityClient) var connectivityClient

    init() {
        Task {
            for await result in await connectivityClient.begin() {
                await MainActor.run {
                    if let drill = self.selectedDrill {
                        self.drill = drill
                        self.result = result
                    }
                }
            }
        }
    }

    func start(drill: Drill) {
        guard runState == .stopped else { return }

        runState = .loading

        startDate = Date()
        selectedDrill = drill

        let context = DrillContext(
            title: drill.title,
            attempts: drill.attempts,
            isFailable: drill.isFailable,
            isActive: true
        )

        Task {
            let response = await connectivityClient.sendDrillContext(context)

            await MainActor.run {
                if response == .success {
                    runState = .running
                }

                if response == .failure(.notReachable) {
                    runState = .stopped
                    connectivityError = .notReachable
                }

                if response == .failure(.notReady) {
                    runState = .stopped
                    connectivityError = .notReady
                }
            }
        }
    }

    func stop() {
        selectedDrill = nil

        let context = DrillContext(title: "", attempts: 0, isFailable: false, isActive: false)

        Task {
            await connectivityClient.sendDrillContext(context)
        }
    }
}
