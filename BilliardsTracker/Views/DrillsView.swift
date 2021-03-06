//
//  DrillsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import SwiftUI

struct DrillsView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var store: StoreManager

    private var isBlurred = false

    var body: some View {
        ScrollView {
            ForEach(store.drills) { drill in
                DrillView(drill: drill)
                    .padding([.horizontal], .drillViewPadding * 2)
                    .padding([.vertical], .drillViewPadding)
                    .transition(.slide)
            }
            .blur(radius: isBlurred ? .blurValue : 0)
        }
        .fixFlickering()
        .overlay(session.runState == .loading ? AnyView(loadingView) : AnyView(EmptyView()))
        .disabled(session.runState == .loading)
        .alert(item: $session.connectivityError) { error in
            switch error {
            case .notReady:
                return notReadyAlert
            case .notReachable:
                return notReachableAlert
            }
        }
        .background(
            Color.clear.alert(item: $store.savingError) { _ in
                savingAlert
            }
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

    private var savingAlert: Alert {
        Alert(title: Text("Something went wrong!"),
              message: Text("Latest changes will not be saved."),
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

// swiftlint:disable force_try
struct DrillsView_Previews: PreviewProvider {
    static var drillStore = try! DrillStore(inMemory: true, isPreview: true)
    static var session = SessionManager(store: drillStore)
    static var store = StoreManager(store: drillStore)

    static var view: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            DrillsView()
                .environmentObject(session)
                .environmentObject(store)
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
