//
//  NetworkLogUIProvidable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import SwiftUI

    @MainActor
    public protocol NetworkLogUIProvidable: Sendable {
        func makeNetworkLogsScene() -> AnyView
    }

    private struct EmptyNetworkLogUIProvider: NetworkLogUIProvidable {
        func makeNetworkLogsScene() -> AnyView {
            AnyView(Text("NetworkLogUIProvider not found."))
        }
    }

    extension EnvironmentValues {
        @Entry public var networkLogUIProvider: any NetworkLogUIProvidable = EmptyNetworkLogUIProvider()
    }
#endif
