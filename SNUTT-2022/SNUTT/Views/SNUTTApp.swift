//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

// TODO: change this
class Storage: AuthStorage {
    var apiKey: ApiKey = ""
    var accessToken: AccessToken = ""
}

@main
struct SNUTTApp: App {
    let container: DIContainer

    init() {
        let appEnvironment = AppEnvironment.bootstrap()
        container = appEnvironment.container
    }

    var body: some Scene {
        WindowGroup {
            SNUTTView(container: container)
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
