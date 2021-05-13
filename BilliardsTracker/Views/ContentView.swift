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

            ScrollView {
                ForEach(manager.drills) { drill in
                    HStack {
                        DrillView(drill: drill)
                            .padding(8)
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

struct ContentView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))

    static var previews: some View {
        ContentView()
            .environmentObject(manager)
    }
}
