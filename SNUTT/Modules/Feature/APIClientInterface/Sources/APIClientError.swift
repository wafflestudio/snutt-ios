//
//  APIClientError.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import OpenAPIRuntime

public protocol APIClientError {
    var localizedCode: LocalizedErrorCode? { get }
}

extension ClientError: APIClientError {
    public var localizedCode: LocalizedErrorCode? {
        underlyingError as? LocalizedErrorCode
    }
}
