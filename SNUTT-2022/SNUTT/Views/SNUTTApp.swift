//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

@main
struct SNUTTApp: App {
    let appEnvironment: AppEnvironment

    init() {
        appEnvironment = AppEnvironment.bootstrap()

        /// We need to load access token ASAP in order to determine which screen to show first.
        /// Note that this should run synchronously on the main thread.
        appEnvironment.container.services.authService.loadAccessTokenDuringBootstrap()
    }

    var body: some Scene {
        WindowGroup {
            SNUTTView(viewModel: .init(container: appEnvironment.container))
                .environment(\.dependencyContainer, appEnvironment.container)
        }
    }
}
