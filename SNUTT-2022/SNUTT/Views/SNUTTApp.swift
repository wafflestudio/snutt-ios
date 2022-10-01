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
    }

    var body: some Scene {
        WindowGroup {
            SNUTTView(viewModel: .init(container: appEnvironment.container))
                .environment(\.dependencyContainer, appEnvironment.container)
        }
    }
}
