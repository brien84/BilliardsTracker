//
//  GesturesToggle.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-14.
//

import ComposableArchitecture
import SwiftUI

private extension GesturesToggle {
    struct State: Equatable {
        let gesturesEnabled: Bool
    }

    enum Action: Equatable {
        case didToggleGestures(Bool)
    }
}

private extension SessionSetup.State {
    var state: GesturesToggle.State {
        .init(gesturesEnabled: self.gesturesEnabled)
    }
}

private extension GesturesToggle.Action {
    var action: SessionSetup.Action {
        switch self {
        case .didToggleGestures(let gesturesEnabled):
            return .didToggleGestures(gesturesEnabled)
        }
    }
}

struct GesturesToggle: SessionSetupSubview {
    let store: StoreOf<SessionSetup>

    var color: Color = .clear

    private var gesturesBackground: Color? {
        if #available(watchOS 10, *) {
            return color.opacity(Self.tintOpacity)
        } else {
            return Color.black
        }
    }

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            GeometryReader { proxy in
                List {
                    Toggle("Gesture Recognition", isOn: viewStore.binding(
                        get: \.gesturesEnabled,
                        send: Self.Action.didToggleGestures
                    ))
                    .foregroundStyle(Color.primaryElement)
                    .listItemTint(color.opacity(Self.tintOpacity))
                    .tint(color)

                    GesturesView()
                        .frame(height: proxy.size.height + proxy.safeAreaInsets.top)
                        .listItemTint(gesturesBackground)
                        .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    let store = Store(
        initialState: SessionSetup.State(mode: .standalone),
        reducer: SessionSetup()
    )

    return GesturesToggle(store: store)
        .color(.orange)
}
