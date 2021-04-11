//
//  DrillManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-04.
//

import Combine
import WatchConnectivity

final class DrillManager: NSObject, ObservableObject {
    private let session = WCSession.default

    private let drillStore = CoreDataManager()

    @Published var drills = [Drill]()

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()

        session.delegate = self
        session.activate()

        drillStore.didSaveContext.sink { [weak self] in
            self?.drills = self?.drillStore.getAllDrills() ?? []
        }
        .store(in: &cancellables)

        drills = drillStore.getAllDrills()
    }

    func addDrill(title: String, attempts: Int) {
        drillStore.createDrill(title: title, attempts: attempts)
    }

    private var currentDrill: Drill?

    @Published var isRunning = false

    func start(drill: Drill) {
        currentDrill = drill

        let context = DrillContext(title: drill.title, attempts: drill.attempts, isActive: true)
        guard let data = try? JSONEncoder().encode(context) else { return }

        session.sendMessageData(data) { reply in
            DispatchQueue.main.async {
                self.isRunning = true
            }
        } errorHandler: { error in
            print(error)
        }
    }

    func stop() {
        currentDrill = nil
        isRunning = false

        let context = DrillContext(title: "", attempts: 0, isActive: false)
        guard let data = try? JSONEncoder().encode(context) else { return }

        session.sendMessageData(data) { reply in

        } errorHandler: { error in
            print(error)
        }
    }

    func addResult(_ context: ResultContext, to drill: Drill) {
        drillStore.createResult(from: context, in: drill)
    }
}

extension DrillManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        guard let context = try? JSONDecoder().decode(ResultContext.self, from: messageData) else { return }

        DispatchQueue.main.async { [self] in
            if let drill = currentDrill {
                addResult(context, to: drill)
            }

            replyHandler(messageData)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith: \(activationState.rawValue)")
        if let error = error { print(error) }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
}
