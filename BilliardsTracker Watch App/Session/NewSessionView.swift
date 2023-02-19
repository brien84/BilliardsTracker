//
//  NewSessionView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

private extension NewSessionView {
    struct State: Equatable {
        let currentTab: Session.Tab
    }

    enum Action: Equatable {
        case didChangeCurrentTab(Session.Tab)
    }
}

private extension Session.State {
    var state: NewSessionView.State {
        .init(currentTab: self.currentTab)
    }
}

private extension NewSessionView.Action {
    var action: Session.Action {
        switch self {
        case .didChangeCurrentTab(let tab):
            return .didChangeCurrentTab(tab)
        }
    }
}

struct NewSessionView: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            TabView(selection:
                viewStore.binding(
                    get: \.currentTab,
                    send: NewSessionView.Action.didChangeCurrentTab
                )
            ) {
                SessionProgressView(store: store)
                    .tag(Session.Tab.progress)

                SessionControlView(store: store)
                    .tag(Session.Tab.control)
            }
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
