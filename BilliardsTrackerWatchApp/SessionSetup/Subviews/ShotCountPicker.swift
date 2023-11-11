//
//  ShotCountPicker.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-10.
//

import ComposableArchitecture
import SwiftUI

private extension ShotCountPicker {
    struct State: Equatable {
        let shotCount: Int
    }

    enum Action: Equatable {
        case setNavigationToShotCountPicker(isActive: Bool)
        case shotCountDidChange(Int)
    }
}

private extension SessionSetup.State {
    var state: ShotCountPicker.State {
        .init(shotCount: self.shotCount)
    }
}

private extension ShotCountPicker.Action {
    var action: SessionSetup.Action {
        switch self {
        case .setNavigationToShotCountPicker(let isActive):
            return .setNavigationToShotCountPicker(isActive: isActive)
        case .shotCountDidChange(let shotCount):
            return .shotCountDidChange(shotCount)
        }
    }
}

struct ShotCountPicker: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            VStack {
                Picker(selection: viewStore.binding(
                    get: \.shotCount,
                    send: Self.Action.shotCountDidChange
                )) {
                    ForEach(2..<151) { i in
                        Text("\(i)")
                            .font(.title2)
                            .tag(i)
                    }
                } label: {
                    Text("Shot Count")
                        .font(.headline)
                }

                Button("Done") {
                    viewStore.send(.setNavigationToShotCountPicker(isActive: false))
                }
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

    return ShotCountPicker(store: store)
        .foregroundStyle(Color.orange)
        .tint(Color.orange)
}
