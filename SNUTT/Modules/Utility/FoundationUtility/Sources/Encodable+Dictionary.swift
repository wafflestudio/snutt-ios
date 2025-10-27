//
//  Encodable+Dictionary.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

extension Encodable {
    public var stringDictionary: [String: String] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed))
            .flatMap { $0 as? [String: String] } ?? [:]
    }
}
