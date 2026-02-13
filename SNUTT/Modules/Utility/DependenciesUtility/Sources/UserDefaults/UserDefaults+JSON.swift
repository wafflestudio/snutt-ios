//
//  UserDefaults+JSON.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import Foundation

extension UserDefaults.Dependency {
    public func object<T>(forKey key: String, type _: T.Type) throws -> T where T: Sendable & Codable {
        let decoder = JSONDecoder()
        guard let data = data(forKey: key) else { throw UserDefaultsError.notFound }
        let object = try decoder.decode(T.self, from: data)
        return object
    }
}

public enum UserDefaultsError: Error {
    case notFound
}
