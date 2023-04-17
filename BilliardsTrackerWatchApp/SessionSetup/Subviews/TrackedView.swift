//
//  TrackedView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-03-06.
//

import ComposableArchitecture
import SwiftUI

private extension TrackedView {
    struct State: Equatable {
        var isNavigationToSessionActive: Bool
    }

    enum Action: Equatable {
        case establishConnection
        case endConnection
    }
}

private extension SessionSetup.State {
    var state: TrackedView.State {
        .init(isNavigationToSessionActive: isNavigationToSessionActive)
    }
}

private extension TrackedView.Action {
    var action: SessionSetup.Action {
        switch self {
        case .establishConnection:
            return .establishConnection
        case .endConnection:
            return .endConnection
        }
    }
}

struct TrackedView: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store, observe: \.state, send: \Action.action) { viewStore in
            VStack(spacing: Self.verticalSpacing) {
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
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.primaryElement)
            }
            .navigationBarBackButtonHidden(viewStore.isNavigationToSessionActive)
            .onAppear {
                viewStore.send(.establishConnection)
            }
            .onDisappear {
                viewStore.send(.endConnection)
            }
        }
    }
}

// MARK: - Constants

private extension TrackedView {
    static let iconSize: CGSize = CGSize(width: 36, height: 36)
    static let iphoneFontSize: CGFloat = 72
    static let iconOffset: CGSize = CGSize(width: 12, height: -5)
    static let iphoneOffset: CGSize = CGSize(width: -12, height: 0)
    static let verticalSpacing: CGFloat = 16
}

// MARK: - Previews

struct TrackedView_Previews: PreviewProvider {
    static let store = Store(
        initialState: SessionSetup.State(mode: .tracked),
        reducer: SessionSetup()
    )

    static var previews: some View {
        TrackedView(store: store)
    }
}
