//
//  Collection+Safe.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public func get(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
