//
//  TrackedActivationView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-04-02.
//

import ComposableArchitecture
import SwiftUI

struct TrackedActivationView: View {
    let store: StoreOf<TrackedActivation>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                PassiveNavigationLink(
                    isActive: viewStore.binding(
                        get: \.isNavigationToSessionActive,
                        send: TrackedActivation.Action.setNavigationToSession
                    ),
                    destination: {
                        SessionView(store: store.scope(
                            state: \.session,
                            action: TrackedActivation.Action.session
                        ))
                    }
                )

                VStack {
                    ZStack(alignment: .bottom) {
                        Image(systemName: "iphone")
                            .font(.system(size: Self.iphoneFontSize, weight: .ultraLight))
                            .foregroundColor(.accentColor)
                            .offset(Self.iphoneOffset)

                        Image("icon")
                            .resizable()
                            .frame(width: Self.iconSize.width, height: Self.iconSize.height)
                            .offset(Self.iconOffset)
                    }

                    Text("Select a drill on BilliardsTracker iPhone application")
                        .font(.caption)
                        .foregroundColor(.primaryElement)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(Self.scaleFactor)
                }
                .onAppear {
                    viewStore.send(.establishConnection)
                }
                .onDisappear {
                    viewStore.send(.endConnection)
                }
            }
        }
    }
}

// MARK: - Constants

private extension TrackedActivationView {
    static let iconOffset: CGSize = CGSize(width: 12, height: -5)
    static let iconSize: CGSize = CGSize(width: 36, height: 36)
    static let iphoneFontSize: CGFloat = 72
    static let iphoneOffset: CGSize = CGSize(width: -12, height: 0)
    static let scaleFactor: CGFloat = 0.9
}

// MARK: - Previews

struct TrackedActivationView_Previews: PreviewProvider {
    static let store = Store(
        initialState: TrackedActivation.State(),
        reducer: TrackedActivation()
    )

    static var previews: some View {
        TrackedActivationView(store: store)
    }
}
