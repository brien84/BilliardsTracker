//
//  RestartingToggle.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-11.
//

import ComposableArchitecture
import SwiftUI

private extension RestartingToggle {
    struct State: Equatable {
        let isRestarting: Bool
    }

    enum Action: Equatable {
        case isRestartingDidChange(Bool)
    }
}

private extension SessionSetup.State {
    var state: RestartingToggle.State {
        .init(isRestarting: self.isRestarting)
    }
}

private extension RestartingToggle.Action {
    var action: SessionSetup.Action {
        switch self {
        case .isRestartingDidChange(let isRestarting):
            return .isRestartingDidChange(isRestarting)
        }
    }
}

struct RestartingToggle: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            List {
                Toggle("Restarting", isOn: viewStore.binding(
                    get: \.isRestarting,
                    send: Self.Action.isRestartingDidChange
                ))
                .foregroundStyle(Color.primaryElement)

                Text(
                    """
                    When this option is enabled, non-continuous drill session
                    will automatically restart after the first missed shot.
                    """
                )
                .foregroundStyle(Color.primaryElement)
                .listRowBackground(Color.clear)
            }
        }
    }
}

#Preview {
    let store = Store(
        initialState: SessionSetup.State(mode: .standalone),
        reducer: SessionSetup()
    )

    return RestartingToggle(store: store)
        .foregroundStyle(Color.orange)
        .tint(Color.orange)
}
