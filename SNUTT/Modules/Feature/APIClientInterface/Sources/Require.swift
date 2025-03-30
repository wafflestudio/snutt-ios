//
//  Require.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

public func require<T>(_ optional: T?) throws -> T {
    guard let value = optional else {
        throw LocalizedErrorCode.serverFault
    }
    return value
}
