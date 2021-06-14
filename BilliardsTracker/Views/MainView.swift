//
//  MainView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-14.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var manager: DrillManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                DrillsView()
            }
            .navigationBarItems(leading: settingsButton, trailing: createDrillButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var settingsButton: some View {
        Button(
            action: {

            },
            label: {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.large)
            }
        )
    }

    private var createDrillButton: some View {
        Button(
            action: {

            },
            label: {
                Image(systemName: "plus")
                    .imageScale(.large)
            }
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var view: some View {
        MainView()
            .environmentObject(manager)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
