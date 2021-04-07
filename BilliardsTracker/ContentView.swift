//
//  ContentView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var manager = DrillManager()

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
                }.padding()

                Spacer()

                List {
                    ForEach(manager.drills, id: \.self) { drill in
                        NavigationLink(destination: ResultsView(manager: manager)) {
                            HStack {
                                Text(drill.title ?? "")
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

struct ResultsView: View {
    @ObservedObject var manager: DrillManager

    var body: some View {
        VStack {
            Text("Running drill!")

            List(manager.contexts) { context in
                HStack {
                    Text(String(context.potCount))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.green)
                    Text(String(context.missCount))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                }.padding().font(.title)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
