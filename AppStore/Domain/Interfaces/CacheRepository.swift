//
//  CacheRepository.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

struct UserDefaultsConfig {
    @UserDefault(key: "RECENT_SEARCH_HISTORIES", defaultValue: [])
    static var histories: [String]
}

protocol CacheRepository {
    func getRecentSearchHistory() -> [String]
    func saveSearchHistory(name: String)
}

class DefaultCacheRepository: CacheRepository {
    func getRecentSearchHistory() -> [String] {
        return UserDefaultsConfig.histories
    }
    
    func saveSearchHistory(name: String) {
        var histories = UserDefaultsConfig.histories.filter { $0 != name }
        if histories.count == 10 {
            histories.removeLast()
        }
        histories.insert(name, at: 0)
        UserDefaultsConfig.histories = histories
    }
}
