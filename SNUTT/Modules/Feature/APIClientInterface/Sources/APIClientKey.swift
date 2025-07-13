//
//  APIClientKey.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public enum APIClientKey: TestDependencyKey {
    public static var testValue: any APIProtocol {
        previewValue
    }

    public static var previewValue: any APIProtocol {
        fatalError()
    }
}

extension DependencyValues {
    /// SeeAlso: [SNUTT API Document](https://snutt-api-dev.wafflestudio.com/webjars/swagger-ui/index.html#/)
    public var apiClient: any APIProtocol {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
