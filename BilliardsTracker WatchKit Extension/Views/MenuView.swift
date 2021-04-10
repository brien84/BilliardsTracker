//
//  MenuView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-10.
//

import SwiftUI

struct MenuView: View {
    @State private var currentTab: Int = 0

    var body: some View {
        TabView(selection: $currentTab) {
            NavigationLink(destination: RunnerView(.standalone)) {
                Text("Standalone")
                    .font(.title3)
                    .foregroundColor(.green)
                    .tag(0)
            }

            NavigationLink(destination: RunnerView(.paired)) {
                Text("Paired")
                    .font(.title3)
                    .foregroundColor(.red)
                    .tag(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
