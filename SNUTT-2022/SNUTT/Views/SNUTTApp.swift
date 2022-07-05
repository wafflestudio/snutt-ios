//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

@main
struct SNUTTApp: App {
    let appState = AppState()

    var body: some Scene {
        WindowGroup {
            SNUTTView(appState: appState)
        }
    }
}

extension View {
    func debugChanges() {
        if #available(iOS 15.0, *) {
            Self._printChanges()
        }
    }
}
