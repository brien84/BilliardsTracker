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

    var body: some View {
        VStack {
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

                            if drill.isFailable {
                                Image(systemName: "xmark.seal")
                                    .imageScale(.small)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }

            HStack {
                NavigationLink("Statistics", destination: StatisticsView(drill: drill))
                    .padding()

                deleteButton
                    .padding()
            }
        }
    }

    private var navigationLink: some View {
        let navigationBinding = Binding<Bool>(
                                    get: { manager.runState == .running && manager.selectedDrill == drill },
                                    set: { manager.runState = $0 ? .running : .stopped }
                                ).removeDuplictates()

        return NavigationLink(destination: RunningView(),
                              isActive: navigationBinding) { EmptyView() }.disabled(true)
    }

    @State private var shouldDelete = false

    private var deleteButton: some View {
        Button {
            shouldDelete = true
        } label: {
            Text("Delete")
        }
        .alert(isPresented: $shouldDelete, content: {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to delete this drill?"),
                primaryButton: .destructive(Text("Delete")) {
                    manager.delete(drill: drill)
                },
                secondaryButton: .cancel()
            )
        })
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
