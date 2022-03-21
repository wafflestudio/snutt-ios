//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

/// Wrapper struct that supports both iOS 13 and iOS 14 (and above).
@main
struct SNUTTAppWrapper {
    static func main() {
        if #available(iOS 14.0, *) {
            SNUTTApp.main()
        } else {
            /// In iOS 13, use `SceneDelegate` instead of `@main`.
            UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(SceneDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct SNUTTApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
