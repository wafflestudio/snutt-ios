//
//  BaseViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/05/23.
//

import SwiftUI

class BaseViewModel {
    var container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    var appState: AppState {
        container.appState
    }

    var services: AppEnvironment.Services {
        container.services
    }
}
