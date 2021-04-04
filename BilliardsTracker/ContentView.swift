//
//  ContentView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var manager = DrillManager()

    var body: some View {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
