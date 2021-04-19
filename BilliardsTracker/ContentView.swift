//
//  ContentView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: DrillManager

    @State private var title = ""
    @State private var attempts = 1.0

    var body: some View {
        NavigationView {

            VStack {
                TextField("Drill Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Slider(value: $attempts, in: 1...100, step: 1.0)
                    .padding(.horizontal)

                Text(String(Int(attempts)))

                Button("Save") {
                    manager.addDrill(title: title, attempts: Int(attempts))
                    title = ""
                    attempts = 1.0
                }
                .padding()

                Divider()

                List {
                    ForEach(manager.drills) { drill in
                        DrillView(drill: drill)
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            manager.deleteDrills(offsets: indexSet)
                        }
                    }
                }
            }
            .navigationBarTitle("Drills")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var manager = DrillManager(store: DrillStore(inMemory: true))

    static var previews: some View {
        ContentView()
            .environmentObject(manager)
    }
}
