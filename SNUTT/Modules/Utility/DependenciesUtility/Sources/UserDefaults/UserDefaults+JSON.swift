//
//  UserDefaults+JSON.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import DependenciesAdditions

extension UserDefaults.Dependency {
    public func object<T>(forKey key: String, type: T.Type) throws -> T where T: Sendable & Codable {
        let decoder = JSONDecoder()
        guard let data = data(forKey: key) else { throw UserDefaultsError.notFound }
        let object = try decoder.decode(T.self, from: data)
        return object
    }
}

public enum UserDefaultsError: Error {
    case notFound
}
