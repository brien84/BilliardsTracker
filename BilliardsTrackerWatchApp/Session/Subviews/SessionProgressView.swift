//
//  SessionProgressView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

private extension SessionProgressView {
    struct State: Equatable {
        let title: String
        let shotCount: Int
        let potCount: Int
        let missCount: Int
        let remainingShots: Int
        let isPaused: Bool

        var remainingShotsPercentage: CGFloat {
            guard shotCount > 0 else { return 0 }
            return CGFloat(remainingShots) / CGFloat(shotCount)
        }

        init(state: Session.State) {
            self.title = state.title
            self.shotCount = state.shotCount
            self.potCount = state.potCount
            self.missCount = state.missCount
            self.remainingShots = state.remainingShots
            self.isPaused = state.isPaused
        }
    }

    enum Action: Equatable {
        case didRegisterShot(isSuccess: Bool)
    }
}

private extension Session.State {
    var state: SessionProgressView.State {
        .init(state: self)
    }
}

private extension SessionProgressView.Action {
    var action: Session.Action {
        switch self {
        case .didRegisterShot(isSuccess: let isSuccess):
            return .didRegisterShot(isSuccess: isSuccess)
        }
    }
}

struct SessionProgressView: View {
    let store: StoreOf<Session>

    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            VStack {
                MarqueeText(viewStore.title)
                    .font(.headline)
                    .foregroundColor(.primaryElement)
                    .padding(.top)
                    .opacity(isLuminanceReduced ? 0 : 1)

                Spacer()

                ProgressView(value: viewStore.remainingShotsPercentage) {
                    Text("\(viewStore.remainingShots)")
                        .font(.title3.bold())
                        .foregroundColor(.primaryElement)
                }
                .progressViewStyle(.circular)
                .tint(viewStore.isPaused ? .secondaryElement : .customBlue)

                Spacer()

                HStack {
                    Button {
                        viewStore.send(.didRegisterShot(isSuccess: true), animation: .default)
                    } label: {
                        Text("\(viewStore.potCount)")
                            .font(.title3.bold())
                            .foregroundColor(.customGreen)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customGreen)
                    .accessibilityLabel("Register Potted Ball")

                    Button {
                        viewStore.send(.didRegisterShot(isSuccess: false), animation: .default)
                    } label: {
                        Text("\(viewStore.missCount)")
                            .font(.title3.bold())
                            .foregroundColor(.customRed)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customRed)
                    .accessibilityLabel("Register Missed Ball")
                }
                .disabled(viewStore.isPaused)
            }
        }
    }
}

// MARK: - Previews

struct SessionProgressView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(
            mode: .standalone,
            title: "Preview",
            shotCount: 9,
            isContinuous: true,
            isRestarting: false,
            gesturesEnabled: true
        ),
        reducer: Session()
    )

    static var previews: some View {
        SessionProgressView(store: store)
    }
}
