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

    private var appState: AppState {
        container.appState
    }
}
