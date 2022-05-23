//
//  SNUTTViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 2022/05/23.
//

import SwiftUI

class AppStateContainer {
    
    fileprivate var appState: AppState?
    
    static let shared = AppStateContainer()
    private init() { }
    
    func setAppState(appState: AppState) {
        self.appState = appState
    }
}

class SNUTTViewModel: ObservableObject {
    
    var appState: AppState
    
    init() {
        appState = AppStateContainer.shared.appState!
    }
}

