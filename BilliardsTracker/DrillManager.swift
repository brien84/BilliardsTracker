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
    @Published var contexts = [ResultContext]()

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
}

extension DrillManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        guard let context = try? JSONDecoder().decode(ResultContext.self, from: messageData) else { return }

        DispatchQueue.main.async {
            self.contexts.append(context)
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
