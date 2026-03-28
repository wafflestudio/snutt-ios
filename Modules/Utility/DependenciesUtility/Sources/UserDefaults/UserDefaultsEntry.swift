//
//  UserDefaultsEntry.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import Foundation

extension UserDefaults.Dependency {
    public subscript<Value>(
        keyPath: KeyPath<UserDefaultsEntryDefinitions, UserDefaultsEntry<Value>>
    ) -> Value {
        get {
            let entry = UserDefaultsEntryDefinitions()[keyPath: keyPath]
            let object = try? object(forKey: entry.key, type: Value.self)
            return object ?? entry.defaultValue
        }
        nonmutating set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            let entry = UserDefaultsEntryDefinitions()[keyPath: keyPath]
            set(data, forKey: entry.key)
        }
    }
}

public struct UserDefaultsEntry<Value: Codable & Sendable> {
    public let key: String
    public let defaultValue: Value

    public init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

public struct UserDefaultsEntryDefinitions: Sendable {}
