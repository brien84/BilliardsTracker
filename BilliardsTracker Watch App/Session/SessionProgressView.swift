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

        init(session: Session.State) {
            self.title = session.title
            self.shotCount = session.shotCount
            self.potCount = session.potCount
            self.missCount = session.missCount
            self.remainingShots = session.remainingShots
            self.isPaused = session.isPaused
        }
    }

    enum Action: Equatable {
        case didRegisterShot(isSuccess: Bool)
    }
}

private extension Session.State {
    var state: SessionProgressView.State {
        .init(session: self)
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

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            VStack {
                MarqueeText(viewStore.title, font: .headline)
                    .padding(.top)
                    .foregroundColor(.primaryElement)

                Spacer()

                ProgressView(value: viewStore.remainingShotsPercentage) {
                    Text("\(viewStore.shotCount - viewStore.potCount - viewStore.missCount)")
                        .bold()
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
                            .foregroundColor(.customGreen)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customGreen)

                    Button {
                        viewStore.send(.didRegisterShot(isSuccess: false), animation: .default)
                    } label: {
                        Text("\(viewStore.missCount)")
                            .foregroundColor(.customRed)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customRed)
                }
                .disabled(viewStore.isPaused)
            }
        }
    }
}

// MARK: - Previews

struct SessionProgressView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(title: "Preview", shotCount: 9),
        reducer: Session()
    )

    static var previews: some View {
        SessionProgressView(store: store)
    }
}
