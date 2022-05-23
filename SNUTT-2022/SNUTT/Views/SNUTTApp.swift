//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

@main
struct SNUTTApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        let _ = AppStateContainer.shared.setAppState(appState: appState)
        
        WindowGroup {
            NavigationView {
                MyTimetableListScene(viewModel: TimetableViewModel())
            }
        }
    }
}
