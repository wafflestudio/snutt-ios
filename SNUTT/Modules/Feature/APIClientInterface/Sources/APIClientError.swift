//
//  APIClientError.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import OpenAPIRuntime

public typealias APIClientError = ClientError

public enum ParsingError: Error {
    case preprocessFailed
    case postprocessFailed
}
