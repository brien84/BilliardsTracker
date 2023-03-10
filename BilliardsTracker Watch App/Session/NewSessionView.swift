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
        let isNavigationToResultActive: Bool

        var alert: AlertState<Session.Action>?

        init(state: Session.State) {
            self.currentTab = state.currentTab
            self.isNavigationToResultActive = state.result != nil
            self.alert = state.alert
        }
    }

    enum Action: Equatable {
        case didChangeCurrentTab(Session.Tab)

        case alertDidDismiss
        case onAppear
    }
}

private extension Session.State {
    var state: NewSessionView.State {
        .init(state: self)
    }
}

private extension NewSessionView.Action {
    var action: Session.Action {
        switch self {
        case .didChangeCurrentTab(let tab):
            return .didChangeCurrentTab(tab)

        case .alertDidDismiss:
            return .alertDidDismiss

        case .onAppear:
            return .onAppear
        }
    }
}

struct NewSessionView: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            ZStack {
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
                .tabViewStyle(.page(indexDisplayMode: viewStore.isNavigationToResultActive ? .never : .always))

                IfLetStore(
                    store.scope(
                        state: \.result,
                        action: Session.Action.result
                    ),
                    then: ResultView.init(store:)
                )
                .transition(.move(edge: .bottom))
                .zIndex(1000)
            }
            .alert(
                store.scope(state: \.alert),
                dismiss: .alertDidDismiss
            )
            .onAppear {
                viewStore.send(.onAppear)
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
