//
//  SettingsManager.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-14.
//

import Combine
import Foundation

final class SettingsManager: ObservableObject {
    private var userDefaults: UserDefaults

    @Published var sortOption: SortOption {
        didSet {
            userDefaults.sortOption = sortOption
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.sortOption = userDefaults.sortOption
    }
}

extension UserDefaults {
    enum Keys {
        static let sortOption = "sortOption"
    }

    var sortOptionPublisher: AnyPublisher<SortOption, Never> {
        publisher(for: \.rawSortOption)
            .compactMap { rawValue -> SortOption in
                SortOption(rawValue: rawValue) ?? .title
            }
            .eraseToAnyPublisher()
    }

    fileprivate var sortOption: SortOption {
        get {
            let rawValue = integer(forKey: Keys.sortOption)
            return SortOption(rawValue: rawValue) ?? .title
        }
        set {
            rawSortOption = newValue.rawValue
        }
    }

    @objc private var rawSortOption: Int {
        get {
            integer(forKey: Keys.sortOption)
        }
        set {
            set(newValue, forKey: Keys.sortOption)
        }
    }
}
