//
//  DrillsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct DrillsView: View {
    @EnvironmentObject var manager: DrillManager

    private var isBlurred = false

    var body: some View {
        ScrollView {
            ForEach(manager.drills) { drill in
                DrillView(drill: drill)
                    .padding([.horizontal], .drillViewPadding * 2)
                    .padding([.vertical], .drillViewPadding)
                    .transition(.slide)
            }
            .blur(radius: isBlurred ? .blurValue : 0)
        }
        .fixFlickering()

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


    /// Applies blur effect to `DrillsView`.
    /// This function is required, since applying blur directly on `ScrollView` causes `NavigationView` layout bug.
    func blur(_ isEnabled: Bool) -> some View {
        var view = self
        view.isBlurred = isEnabled
        return view
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

    static var blurValue: CGFloat {
        5
    }
}

struct DrillsView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var view: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            DrillsView()
                .environmentObject(manager)
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
