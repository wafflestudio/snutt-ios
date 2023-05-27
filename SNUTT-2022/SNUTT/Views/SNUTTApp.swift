//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

@main
struct SNUTTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let appEnvironment: AppEnvironment
    let deepLinkHandler: DeepLinkHandler

    init() {
        appEnvironment = AppEnvironment.bootstrap()
        deepLinkHandler = DeepLinkHandler(appState: appEnvironment.container.appState)
    }

    var body: some Scene {
        WindowGroup {
            SNUTTView(viewModel: .init(container: appEnvironment.container))
                .environment(\.dependencyContainer, appEnvironment.container)
                .onOpenURL { url in
                    deepLinkHandler.open(url: url)
                }
        }
    }
}
