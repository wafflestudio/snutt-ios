//
//  KnownVersion.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

/// Versions that have explicit migration steps.
/// - Important: The order of `allCases` defines migration order.
enum KnownVersion: String, CaseIterable, Comparable {
    case v4_0_0

    static func < (lhs: KnownVersion, rhs: KnownVersion) -> Bool {
        guard let lhsIndex = allCases.firstIndex(of: lhs),
            let rhsIndex = allCases.firstIndex(of: rhs)
        else { return false }
        return lhsIndex < rhsIndex
    }
}
