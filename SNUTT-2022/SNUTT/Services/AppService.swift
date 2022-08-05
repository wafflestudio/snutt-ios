//
//  AppService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import Foundation

protocol AppServiceProtocol {
    func toggleMenuSheet()
}

/// A service that modifies miscellaneous global states.
struct AppService: AppServiceProtocol {
    var appState: AppState
    
    func toggleMenuSheet() {
        appState.menu.isOpen.toggle()
    }
}
