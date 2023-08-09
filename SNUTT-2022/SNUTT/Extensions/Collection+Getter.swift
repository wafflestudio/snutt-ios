//
//  Collection+Safe.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/03/18.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    func get(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
