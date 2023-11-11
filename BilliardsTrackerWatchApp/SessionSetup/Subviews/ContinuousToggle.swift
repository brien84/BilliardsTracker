//
//  ContinuousToggle.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-10.
//

import ComposableArchitecture
import SwiftUI

private extension ContinuousToggle {
    struct State: Equatable {
        let isContinuous: Bool
    }

    enum Action: Equatable {
        case isContinuousDidChange(Bool)
    }
}

private extension SessionSetup.State {
    var state: ContinuousToggle.State {
        .init(isContinuous: self.isContinuous)
    }
}

private extension ContinuousToggle.Action {
    var action: SessionSetup.Action {
        switch self {
        case .isContinuousDidChange(let isContinuous):
            return .isContinuousDidChange(isContinuous)
        }
    }
}

struct ContinuousToggle: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            List {
                Toggle("Continuous", isOn: viewStore.binding(
                    get: \.isContinuous,
                    send: Self.Action.isContinuousDidChange
                ))
                .foregroundStyle(Color.primaryElement)

                Text("When this option is disabled, the drill session will end after the first missed shot.")
                    .foregroundStyle(Color.primaryElement)
                    .listRowBackground(Color.clear)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let store = Store(
        initialState: SessionSetup.State(mode: .standalone),
        reducer: SessionSetup()
    )

    return ContinuousToggle(store: store)
        .foregroundStyle(Color.orange)
        .tint(Color.orange)
}
