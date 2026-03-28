//
//  ClientUnknownServerError.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

/// Client-side representation of server errors that aren't predefined in the client.
public struct ClientUnknownServerError: LocalizedError {
    public let errorCode: Int
    public let errorDescription: String?
    public let failureReason: String?
    public let recoverySuggestion: String?

    public init(errorCode: Int, errorDescription: String?, failureReason: String?, recoverySuggestion: String?) {
        self.errorCode = errorCode
        self.errorDescription = errorDescription
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
    }
}
