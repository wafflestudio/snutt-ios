//
//  DIContainer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Combine
import SwiftUI

/// A subset of `AppEnvironment` which is injected into each view models.
struct DIContainer {
    let appState: AppState
    let services: AppEnvironment.Services

    init(appState: AppState, services: AppEnvironment.Services) {
        self.appState = appState
        self.services = services
    }
}

#if DEBUG
    extension DIContainer {
        @MainActor static var preview: Self {
            let appState: AppState = .preview
            return .init(appState: appState, services: .preview(appState: appState))
        }
    }
#endif
