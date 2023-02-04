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
                        Label($0.label, systemImage: $0.imageName)
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
    static let userDefaults: UserDefaults = {
        let userDefaults = UserDefaults(suiteName: #file)
        userDefaults!.removePersistentDomain(forName: #file)
        return userDefaults!
    }()

    static var previews: some View {
        NavigationView {
            Color.primaryBackground
                .toolbar {
                    SettingsView(store: Store(
                        initialState: Settings.State(userDefaults: userDefaults),
                        reducer: Settings()
                    ))
                }
        }
    }
}
