//
//  ContentView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: DrillManager

    @State private var isCreatingDrill = false

    private var createDrillButton: some View {
        Button(action: { isCreatingDrill = true },
               label: { Image(systemName: "plus").imageScale(.large) }
        )
    }

    var body: some View {
        NavigationView {

            List {
                ForEach(manager.drills) { drill in
                    HStack {
                        DrillView(drill: drill)
                    }
                }
                .onDelete { indexSet in
                    withAnimation {
                        manager.deleteDrills(offsets: indexSet)
                    }
                }
            }
            .navigationBarTitle("Drills")
            .navigationBarItems(trailing: createDrillButton)
            .sheet(isPresented: $isCreatingDrill) {
                CreateDrillView(isCreatingDrill: $isCreatingDrill)
            }

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))

    static var previews: some View {
        ContentView()
            .environmentObject(manager)
    }
}
