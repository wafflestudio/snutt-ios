//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation
import SwiftUI
import Combine

class ReviewViewModel: ObservableObject {
    var container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }
    
    var apiKey: String? {
        appState.user.apiKey
    }
    
    var token: String? {
        appState.user.token
    }
    
    var snuevWebUrl: String? {
        appState.setting.snuevWebUrl
    }

    private var appState: AppState {
        container.appState
    }
    
    private var currentUser: User? {
        appState.user.current
    }
}
