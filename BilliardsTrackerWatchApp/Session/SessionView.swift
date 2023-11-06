//
//  SessionView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

private extension SessionView {
    enum Tab: Int {
        case control
        case progress
    }

    struct ViewState: Equatable {
        let alert: AlertState<Session.Action>?
        let didPotLastShot: Bool?
        let isPaused: Bool
        let isNavigationToResultActive: Bool

        init(state: Session.State) {
            self.alert = state.alert
            self.didPotLastShot = state.didPotLastShot
            self.isPaused = state.isPaused
            self.isNavigationToResultActive = state.result != nil
        }
    }

    enum Action: Equatable {
        case didDismissGestureTrackingError
        case onAppear
        case onDisappear
    }

    func changeCurrentTab(to tab: Tab) {
        withAnimation { currentTab = tab }
    }
}

private extension Session.State {
    var state: SessionView.ViewState {
        .init(state: self)
    }
}

private extension SessionView.Action {
    var action: Session.Action {
        switch self {
        case .didDismissGestureTrackingError:
            return .didDismissGestureTrackingError
        case .onAppear:
            return .onAppear
        case .onDisappear:
            return .onDisappear
        }
    }
}

struct SessionView: View {
    let store: StoreOf<Session>

    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    @State private var currentTab = Tab.progress

    init(store: StoreOf<Session>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            ZStack {
                let shouldDisplayTabViewIndex = viewStore.isNavigationToResultActive || isLuminanceReduced
                TabView(selection: $currentTab) {
                    SessionProgressView(store: store)
                        .tag(Tab.progress)

                    SessionControlView(store: store)
                        .tag(Tab.control)
                }
                .tabViewStyle(.page(indexDisplayMode: shouldDisplayTabViewIndex ? .never : .always))

                IfLetStore(
                    store.scope(
                        state: \.result,
                        action: Session.Action.result
                    ),
                    then: ResultView.init(store:)
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            .alert(
                store.scope(state: \.alert),
                dismiss: .didDismissGestureTrackingError
            )
            .onChange(of: viewStore.isPaused) { _ in
                changeCurrentTab(to: .progress)
            }
            .onChange(of: viewStore.didPotLastShot) { newValue in
                guard newValue == nil else { return }
                changeCurrentTab(to: .progress)
            }
            .onChange(of: isLuminanceReduced) { isReduced in
                if isReduced, currentTab == .control {
                    changeCurrentTab(to: .progress)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
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
