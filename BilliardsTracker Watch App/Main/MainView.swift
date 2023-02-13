//
//  MenuView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-13.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                MenuView()
            }
            .environmentObject(viewStore.session)
        }
    }
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
    }
}
