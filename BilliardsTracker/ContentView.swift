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

    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .red))
            .padding()
            .background(Color.primary)
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
        .overlay(manager.runState == .loading ? AnyView(loadingView) : AnyView(EmptyView()))
        .disabled(manager.runState == .loading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))

    static var previews: some View {
        ContentView()
            .environmentObject(manager)
    }
}
