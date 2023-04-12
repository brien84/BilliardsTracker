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
                AppearanceMenu(
                    appearance: viewStore.binding(
                        get: \.appearance,
                        send: Settings.Action.didSelectAppearance
                    ).animation()
                )

                SortingMenu(
                    sortOption: viewStore.binding(
                        get: \.sortOption,
                        send: Settings.Action.didSelectSortOption
                    ).animation(),
                    sortOrder: viewStore.binding(
                        get: \.sortOrder,
                        send: Settings.Action.didSelectSortOrder
                    ).animation()
                )
            }
            label: {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
        }
    }
}

private struct AppearanceMenu: View {
    @Binding var appearance: Appearance

    var body: some View {
        Menu {
            Picker(
                selection: $appearance,
                label: Text("Sorting options")
            ) {
                ForEach(Appearance.allCases) {
                    Label($0.title, systemImage: $0.imageName)
                }
            }
        }
        label: {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
        }
    }
}

private struct SortingMenu: View {
    @Binding var sortOption: SortOption
    @Binding var sortOrder: SortOrder

    var body: some View {
        Menu {
            Picker(
                selection: $sortOption,
                label: Text("Sorting options")
            ) {
                ForEach(SortOption.allCases) {
                    Label($0.title, systemImage: $0.imageName)
                }
            }

            Picker(
                selection: $sortOrder,
                label: Text("Sorting order")
            ) {
                ForEach(SortOrder.allCases) {
                    Text($0.getTitle(for: sortOption))
                }
            }
        }
        label: {
            Label("Sort By", systemImage: "arrow.up.arrow.down")
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
