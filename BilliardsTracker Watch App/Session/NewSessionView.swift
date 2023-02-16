//
//  NewSessionView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

struct NewSessionView: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$currentTab)) {
                SessionProgressView(store: store)
                    .tag(Session.Tab.progress)

                SessionControlView(store: store)
                    .tag(Session.Tab.control)
            }
            .transition(.slide)
        }
    }
}

// MARK: - Previews

struct NewSessionView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(title: "Preview", shotCount: 9),
        reducer: Session()
    )

    static var previews: some View {
        NewSessionView(store: store)
    }
}
