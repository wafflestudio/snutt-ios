//
//  APIClientError.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import OpenAPIRuntime

public protocol APIClientError: Error {
    /// Predefined error code with localized strings (errorDescription, failureReason, recoverySuggestion).
    /// Used when the server error is recognized and has a corresponding enum case.
    var localizedCode: LocalizedErrorCode? { get }
    /// Unknown server error for unrecognized error codes that don't have a predefined LocalizedErrorCode case.
    /// Contains raw error data from server response (errorCode, title, displayMessage).
    var serverError: ClientUnknownServerError? { get }
}

extension ClientError: APIClientError {
    public var localizedCode: LocalizedErrorCode? {
        underlyingError as? LocalizedErrorCode
    }

    public var serverError: ClientUnknownServerError? {
        underlyingError as? ClientUnknownServerError
    }
}

extension APIClientError {
    public var failureReason: String? {
        serverError?.failureReason ?? localizedCode?.failureReason
    }
}
