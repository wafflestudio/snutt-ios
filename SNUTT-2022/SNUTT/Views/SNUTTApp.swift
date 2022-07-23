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
    let appEnvironment: AppEnvironment

    init() {
        appEnvironment = AppEnvironment.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            SNUTTView(container: appEnvironment.container)
                .environment(\.dependencyContainer, appEnvironment.container)
        }
    }
}
