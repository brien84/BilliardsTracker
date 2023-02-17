//
//  SessionControlView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

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

                    }

                    SessionControlButton(
                        title: "Undo",
                        imageName: "arrow.uturn.backward",
                        color: .customBlue
                    ) {

                    }
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

                    SessionControlButton(
                        title: "Resume",
                        imageName: "play",
                        color: .customGreen
                    ) {
                        viewStore.send(.resumeButtonDidTap, animation: .default)
                    }
                    .disabled(!viewStore.isPaused)
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
                .foregroundColor(isEnabled ? .primaryElement : .secondaryElement)
        }
    }
}

// MARK: - Previews

struct SessionControlView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(title: "Preview", shotCount: 9),
        reducer: Session()
    )

    static var previews: some View {
        SessionControlView(store: store)
    }
}
