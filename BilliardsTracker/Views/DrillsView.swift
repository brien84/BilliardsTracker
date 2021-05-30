//
//  DrillsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct DrillsView: View {
    @EnvironmentObject var manager: DrillManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    ForEach(manager.drills) { drill in
                        DrillView(drill: drill)
                            .padding([.horizontal], .drillViewPadding * 2)
                            .padding([.vertical], .drillViewPadding)
                    }
                }
                .fixFlickering()
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
                return notReadyAlert
            case .notReachable:
                return notReachableAlert
            }
        }
    }

    @State private var isCreatingDrill = false

    private var createDrillButton: some View {
        Button(action: { isCreatingDrill = true },
               label: { Image(systemName: "plus").imageScale(.large) }
        )
    }

    private var loadingView: some View {
        ProgressView()
            .padding()
            .progressViewStyle(CircularProgressViewStyle(tint: .primaryElement))
            .background(Color.secondaryBackground)
            .cornerRadius(.loadingViewCornerRadius)
            .overlay(RoundedRectangle(cornerRadius: .loadingViewCornerRadius)
                        .stroke(Color.secondaryElement, lineWidth: .loadingViewLineWidth))
    }

    private var notReadyAlert: Alert {
        Alert(title: Text("Watch app is not in Tracked mode!"),
              message: Text("Make sure Tracked mode is selected in Watch app."),
              dismissButton: .default(Text("OK")))
    }

    private var notReachableAlert: Alert {
        Alert(title: Text("Watch app is not reachable!"),
              message: Text("Make sure BilliardsTracker Watch app is installed and running."),
              dismissButton: .default(Text("OK")))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var view: some View {
        DrillsView()
            .environmentObject(manager)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}

private extension CGFloat {
    static var drillViewPadding: CGFloat {
        8
    }

    static var loadingViewCornerRadius: CGFloat {
        10
    }

    static var loadingViewLineWidth: CGFloat {
        1
    }
}
