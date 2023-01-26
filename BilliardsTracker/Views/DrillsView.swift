//
//  DrillsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import ComposableArchitecture
import SwiftUI

struct DrillsView: View {
    let store: StoreOf<DrillList>

    init(store: StoreOf<DrillList>) {
        self.store = store
    }

    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var session: SessionManager

    private var isBlurred = false

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                ForEach(viewStore.drills) { drill in
                    DrillView(store: store, drill: drill)
                        .padding([.horizontal], .drillViewPadding * 2)
                        .padding([.vertical], .drillViewPadding)
                        .transition(.slide)
                }
                .blur(radius: isBlurred ? .blurValue : 0)
            }
            .overlay(session.runState == .loading ? AnyView(loadingView) : AnyView(EmptyView()))
        }
    }

    private var loadingView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(colorScheme == .light ? .loadingViewBackgroundOpacityLight : .loadingViewBackgroundOpacityDark)

            ProgressView()
                .padding()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryElement))
                .background(Color.secondaryBackground)
                .cornerRadius(.loadingViewCornerRadius)
                .overlay(RoundedRectangle(cornerRadius: .loadingViewCornerRadius)
                            .stroke(Color.secondaryElement, lineWidth: .loadingViewLineWidth))
        }
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

private extension Double {
    static var loadingViewBackgroundOpacityLight: Double {
        0.25
    }

    static var loadingViewBackgroundOpacityDark: Double {
        0.45
    }
}

// struct DrillsView_Previews: PreviewProvider {
//     static var drillStore = try! DrillStore(inMemory: true, isPreview: true)
//     static var session = SessionManager(store: drillStore)
//     static var store = StoreManager(store: drillStore)
//
//     static var view: some View {
//         ZStack {
//             Color.primaryBackground
//                 .ignoresSafeArea()
//
//             DrillsView()
//                 .environmentObject(session)
//                 .environmentObject(store)
//         }
//     }
//
//     static var previews: some View {
//         view.preferredColorScheme(.light)
//         view.preferredColorScheme(.dark)
//     }
// }
