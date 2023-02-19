//
//  StandaloneView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-19.
//

import ComposableArchitecture
import SwiftUI

struct StandaloneView: View {
    let store: StoreOf<Standalone>

    struct ViewState: Equatable {
        let isNavigationToSessionActive: Bool
        let shotCount: Int

        init(state: Standalone.State) {
            self.isNavigationToSessionActive = state.session != nil
            self.shotCount = state.shotCount
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            ZStack {
                VStack {
                    Text("Shots")
                        .font(.footnote)

                    Divider()

                    Picker("Set shot count",
                        selection: viewStore.binding(
                            get: \.shotCount,
                            send: Standalone.Action.shotCountDidChange
                        )
                    ) {
                        ForEach(1..<101) { i in
                            Text("\(i)")
                                .tag(i)
                                .font(i == viewStore.shotCount ? .title2 : .title3)
                                .foregroundColor(i == viewStore.shotCount ? .primaryElement : .secondaryElement)
                        }
                    }
                    .borderHidden()
                    .labelsHidden()

                    Divider()

                    Button("Start") {
                        viewStore.send(.setNavigationToSession(isActive: true), animation: .default)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customBlue)
                }

                IfLetStore(
                    store.scope(
                        state: \.session,
                        action: Standalone.Action.session
                    ),
                    then: NewSessionView.init(store:)
                )
                .transition(.slide)
                .zIndex(100)
            }
            .navigationBarBackButtonHidden(viewStore.isNavigationToSessionActive)
        }
    }
}

private extension Picker {
    func borderHidden() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 5)
        )
    }
}

// MARK: - Previews

struct StandaloneView_Previews: PreviewProvider {
    static var previews: some View {
        StandaloneView(store: Store(initialState: Standalone.State(), reducer: Standalone()))
    }
}
