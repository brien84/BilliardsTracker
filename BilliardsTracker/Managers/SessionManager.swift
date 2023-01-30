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

    @Published var runState: SessionState = .stopped {
        didSet {
            if runState == .stopped {
                stop()
            }
        }
    }

    @Dependency(\.connectivityClient) var connectivityClient

    func start(drill: Drill) {
        guard runState == .stopped else { return }

        runState = .loading

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
        let context = DrillContext(title: "", attempts: 0, isFailable: false, isActive: false)

        Task {
            await connectivityClient.sendDrillContext(context)
        }
    }
}
