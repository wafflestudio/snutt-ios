//
//  DIContainer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import SwiftUI
import Combine


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
    static var preview: Self {
        .init(appState: .preview, services: .preview)
    }
}
#endif

