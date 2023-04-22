//
//  SessionControlView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

private extension SessionControlView {
    struct State: Equatable {
        let didPotLastShot: Bool?
        let isPaused: Bool

        init(state: Session.State) {
            self.didPotLastShot = state.didPotLastShot
            self.isPaused = state.isPaused
        }
    }

    enum Action: Equatable {
        case pauseButtonDidTap
        case resumeButtonDidTap
        case stopButtonDidTap
        case undoButtonDidTap
    }
}

private extension Session.State {
    var state: SessionControlView.State {
        .init(state: self)
    }
}

private extension SessionControlView.Action {
    var action: Session.Action {
        switch self {
        case .pauseButtonDidTap:
            return .pauseButtonDidTap
        case .resumeButtonDidTap:
            return .resumeButtonDidTap
        case .stopButtonDidTap:
            return .stopButtonDidTap
        case .undoButtonDidTap:
            return .undoButtonDidTap
        }
    }
}

struct SessionControlView: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    SessionControlButton(
                        title: "Stop",
                        imageName: "multiply",
                        color: .customRed
                    ) {
                        viewStore.send(.stopButtonDidTap, animation: .default)
                    }
                    .accessibilityLabel("Stop Session")

                    SessionControlButton(
                        title: "Undo",
                        imageName: "arrow.uturn.backward",
                        color: .customBlue
                    ) {
                        viewStore.send(.undoButtonDidTap, animation: .default)
                    }
                    .disabled(viewStore.didPotLastShot == nil)
                    .accessibilityLabel("Undo Session")
                }

                HStack {
                    SessionControlButton(
                        title: "Pause",
                        imageName: "pause",
                        color: .customYellow
                    ) {
                        viewStore.send(.pauseButtonDidTap, animation: .default)
                    }
                    .disabled(viewStore.isPaused)
                    .accessibilityLabel("Pause Session")

                    SessionControlButton(
                        title: "Resume",
                        imageName: "play",
                        color: .customGreen
                    ) {
                        viewStore.send(.resumeButtonDidTap, animation: .default)
                    }
                    .disabled(!viewStore.isPaused)
                    .accessibilityLabel("Resume Session")
                }
            }
        }
    }
}

private struct SessionControlButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    let imageName: String
    let color: Color
    let action: () -> Void

    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                Image(systemName: imageName)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(color)
                    .padding()
            }
            .buttonStyle(.bordered)
            .tint(color)

            Text(title)
                .font(.footnote)
                .fontWeight(isEnabled ? .medium : .regular)
                .foregroundColor(isEnabled ? .primaryElement : .secondaryElement)
        }
    }
}

// MARK: - Previews

struct SessionControlView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(title: "Preview", shotCount: 9, isContinuous: true),
        reducer: Session()
    )

    static var previews: some View {
        SessionControlView(store: store)
    }
}
