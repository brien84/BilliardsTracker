//
//  SessionSetupView.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-08.
//

import ComposableArchitecture
import SwiftUI

struct SessionSetupView: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store) { _ in
            Text("Session Setup")
        }
    }
}

#Preview {
    let store = Store(
        initialState: SessionSetup.State(),
        reducer: SessionSetup()
    )

    return SessionSetupView(store: store)
}
