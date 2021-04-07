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
                    HStack {
                        Text(drill.title ?? "")
                        Spacer()
                        Text(String(drill.attempts))
                    }
                }
            }

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
