//
//  StandaloneView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-19.
//

import ComposableArchitecture
import SwiftUI

private extension StandaloneView {
    struct State: Equatable {
        var shotCount: Int
        var isNavigationToSessionActive: Bool

        init(_ state: SessionSetup.State) {
            self.shotCount = state.shotCount
            self.isNavigationToSessionActive = state.isNavigationToSessionActive
        }
    }

    enum Action: Equatable {
        case shotCountDidChange(Int)
        case startStandaloneSession
    }
}

private extension SessionSetup.State {
    var state: StandaloneView.State {
        .init(self)
    }
}

private extension StandaloneView.Action {
    var action: SessionSetup.Action {
        switch self {
        case .shotCountDidChange(let count):
            return .shotCountDidChange(count)
        case .startStandaloneSession:
            return .startStandaloneSession
        }
    }
}

struct StandaloneView: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            ZStack {
                VStack {
                    Text("Shots")
                        .font(.footnote)

                    Divider()

                    Picker("Set Shots",
                        selection: viewStore.binding(
                            get: \.shotCount,
                            send: Action.shotCountDidChange
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
                        viewStore.send(.startStandaloneSession, animation: .default)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customBlue)
                }
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
    static let store = Store(
        initialState: SessionSetup.State(mode: .standalone),
        reducer: SessionSetup()
    )

    static var previews: some View {
        StandaloneView(store: store)
    }
}
