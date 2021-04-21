//
//  DrillView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct DrillView: View {
    @EnvironmentObject var manager: DrillManager
    private let drill: Drill

    init(drill: Drill) {
        self.drill = drill
    }

    private var navigationLink: some View {
        let navigationBinding = Binding<Bool>(
                                    get: { manager.runState == .running },
                                    set: { manager.runState = $0 ? .running : .stopped }
                                ).removeDuplictates()

        return NavigationLink(destination: RunningView(drill: drill),
                              isActive: navigationBinding) { EmptyView() }.disabled(true)
    }

    var body: some View {
        Button {
            manager.start(drill: drill)
        } label: {

            ZStack {
                navigationLink

                VStack(spacing: 16) {
                    Text(drill.title)
                        .font(.title)
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                            .imageScale(.small)
                        Text(String(drill.attempts))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }

        }
        .alert(item: $manager.connectivityError) { status in
            switch status {
            case .notReady:
                return Alert(title: Text("Watch app is not in Tracked mode!"),
                      message: Text("Make sure Tracked mode is selected in Watch app."),
                      dismissButton: .default(Text("OK")))
            case .notReachable:
                return Alert(title: Text("Watch app is not reachable!"),
                      message: Text("Make sure BilliardsTracker Watch app is installed and running."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

}

struct DrillView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))
    static var drill = manager.drills.first!

    static var previews: some View {
        DrillView(drill: drill)
            .environmentObject(manager)
    }
}

extension Binding where Value: Equatable {
    /// Workaround for `NavigationLink's `isActive = false` called multiple times per dismissal.
    public func removeDuplictates() -> Binding<Value> {
        var previous: Value? = nil

        return Binding<Value>(
            get: { self.wrappedValue },
            set: { newValue in
                guard newValue != previous else {
                    return
                }
                previous = newValue
                self.wrappedValue = newValue
            }
        )
    }
}
