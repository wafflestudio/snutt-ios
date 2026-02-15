//
//  APIClientError.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import OpenAPIRuntime

public enum APIClientError: Error {
    /// Predefined error code with localized strings (errorDescription, failureReason, recoverySuggestion).
    /// Used when the server error is recognized and has a corresponding enum case.
    case predefined(LocalizedErrorCode)
    /// Unknown server error for unrecognized error codes that don't have a predefined LocalizedErrorCode case.
    /// Contains raw error data from server response (errorCode, title, displayMessage).
    case unknown(ClientUnknownServerError)
}

extension APIClientError {
    public var failureReason: String? {
        switch self {
        case .predefined(let localizedErrorCode):
            localizedErrorCode.failureReason
        case .unknown(let clientUnknownServerError):
            clientUnknownServerError.failureReason
        }
    }
}

extension Error {
    public var apiClientError: APIClientError? {
        switch self {
        case let error as ClientError:
            if let localizedCode = error.underlyingError as? LocalizedErrorCode {
                return .predefined(localizedCode)
            } else if let serverError = error.underlyingError as? ClientUnknownServerError {
                return .unknown(serverError)
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    public var isCancellationError: Bool {
        switch self {
        case is CancellationError:
            return true
        case let error as ClientError where error.underlyingError is CancellationError:
            return true
        case let error as ClientError:
            let nsError = error.underlyingError as NSError
            return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
        default:
            return false
        }
    }

    public var isTimeoutError: Bool {
        switch self {
        case let error as ClientError:
            let nsError = error.underlyingError as NSError
            return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut
        default:
            return false
        }
    }
}
