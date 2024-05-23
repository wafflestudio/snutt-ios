//
//  Composition.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

public enum APIClientKey: TestDependencyKey {
    public static var testValue: any APIProtocol {
        Self.previewValue
    }
    public static let previewValue: any APIProtocol = Client(
        serverURL: URL(string: "https://mock")!,
        configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
        transport: TestClientTransport(callHandler: { _, _, _, _ in throw NSError() }),
        middlewares: []
    )
}

extension DependencyValues {
  public var apiClient: any APIProtocol {
    get { self[APIClientKey.self] }
    set { self[APIClientKey.self] = newValue }
  }
}
