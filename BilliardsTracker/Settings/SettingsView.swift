//
//  SettingsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-13.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<Settings>

    var body: some View {
        WithViewStore(store) { viewStore in
            Menu {
                Picker(
                    selection: viewStore.binding(
                        get: \.sortOption,
                        send: Settings.Action.didSelectSortOption
                    ).animation(),
                    label: Text("Sorting options")
                ) {
                    ForEach(SortOption.allCases) {
                        Label($0.title, systemImage: $0.imageName)
                    }
                }

                Picker(
                    selection: viewStore.binding(
                        get: \.sortOrder,
                        send: Settings.Action.didSelectSortOrder
                    ).animation(),
                    label: Text("Sorting order")
                ) {
                    ForEach(SortOrder.allCases) {
                        Text($0.getTitle(for: viewStore.sortOption))
                    }
                }
            }
            label: {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Settings.State(),
        reducer: Settings()
    )

    static var previews: some View {
        NavigationView {
            Color.primaryBackground
                .toolbar {
                    SettingsView(store: store)
                }
        }
    }
}
