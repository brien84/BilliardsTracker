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

                Spacer()

                List {
                    ForEach(manager.drills) { drill in
                        NavigationLink(destination: RunningView(drill: drill)) {
                            HStack {
                                Text(drill.title)
                                Spacer()
                                Text(String(drill.attempts))
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Drills")
        }.navigationViewStyle(StackNavigationViewStyle())

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
