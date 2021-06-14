//
//  SettingsManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-14.
//

import Foundation

enum SortOption: Int, CaseIterable, Identifiable {
    var id: Self { self }

    case attempts
    case date
    case title
}

final class SettingsManager: ObservableObject {
    @Published var sortOption: SortOption = .title
    @Published var isDarkModeAuto = true
    @Published var isDarkModeOn = false
}
