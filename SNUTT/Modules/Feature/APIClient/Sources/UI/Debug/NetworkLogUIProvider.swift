//
//  NetworkLogUIProvider.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import APIClientInterface
    import SwiftUI

    public struct NetworkLogUIProvider: NetworkLogUIProvidable {
        public init() {}

        public func makeNetworkLogsScene() -> AnyView {
            AnyView(NetworkLogsScene())
        }
    }
#endif
