//
//  BaseViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/05/23.
//

import SwiftUI

@MainActor
protocol BaseViewModelProtocol: Sendable {
    var container: DIContainer { get set }
    var appState: AppState { get }
    var services: AppEnvironment.Services { get }
}

class BaseViewModel: NSObject, BaseViewModelProtocol {
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
