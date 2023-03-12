//
//  SessionView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

private extension SessionView {
    struct State: Equatable {
        let alert: AlertState<Session.Action>?
        let currentTab: Session.Tab
        let isNavigationToResultActive: Bool

        init(state: Session.State) {
            self.alert = state.alert
            self.currentTab = state.currentTab
            self.isNavigationToResultActive = state.result != nil
        }
    }

    enum Action: Equatable {
        case alertDidDismiss
        case beginGestureTracking
        case didChangeCurrentTab(Session.Tab)
    }
}

private extension Session.State {
    var state: SessionView.State {
        .init(state: self)
    }
}

private extension SessionView.Action {
    var action: Session.Action {
        switch self {
        case .alertDidDismiss:
            return .alertDidDismiss

        case .beginGestureTracking:
            return .beginGestureTracking

        case .didChangeCurrentTab(let tab):
            return .didChangeCurrentTab(tab)
        }
    }
}

struct SessionView: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            ZStack {
                TabView(selection:
                    viewStore.binding(
                        get: \.currentTab,
                        send: SessionView.Action.didChangeCurrentTab
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
                viewStore.send(.beginGestureTracking)
            }
        }
    }
}

// MARK: - Previews

struct NewSessionView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(title: "Preview", shotCount: 9, isContinuous: true),
        reducer: Session()
    )

    static var previews: some View {
        SessionView(store: store)
    }
}
