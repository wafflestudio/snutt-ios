//
//  Optional+Unwrapped.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

public enum OptionalError: Swift.Error {
    case unwrappedNil
}

extension Optional {
    public func unwrapped() throws -> Wrapped {
        switch self {
        case .none:
            throw OptionalError.unwrappedNil
        case let .some(value):
            return value
        }
    }
}
