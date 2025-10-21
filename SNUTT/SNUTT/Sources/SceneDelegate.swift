//
//  SceneDelegate.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import FacebookCore
import GoogleSignIn
import KakaoSDKAuth
import SwiftUI
import Timetable
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var hudWindow: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            window = windowScene.keyWindow
            setupHudWindow(in: windowScene)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }

        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
        } else if url.scheme?.hasPrefix("fb") == true {
            ApplicationDelegate.shared.application(
                UIApplication.shared,
                open: url,
                sourceApplication: nil,
                annotation: [UIApplication.OpenURLOptionsKey.annotation]
            )
        } else if url.scheme?.contains("google") == true {
            GIDSignIn.sharedInstance.handle(url)
        } else {
            NotificationCenter.default.post(
                name: Notification.Name("openURL"),
                object: nil,
                userInfo: ["url": url]
            )
        }
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}

extension SceneDelegate {
    func setupHudWindow(in scene: UIWindowScene) {
        let hudWindow = PassthroughWindow(windowScene: scene)
        let hudViewController = UIHostingController(rootView: EmptyView())
        hudViewController.view.backgroundColor = .clear
        hudWindow.rootViewController = hudViewController
        hudWindow.isHidden = false
        self.hudWindow = hudWindow
    }
}

private class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hitView ? nil : hitView
    }
}
