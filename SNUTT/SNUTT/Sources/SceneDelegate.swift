//
//  SceneDelegate.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import UIKit
import SwiftUI
import Timetable

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var keyWindow: UIWindow?
    var hudWindow: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            keyWindow = windowScene.keyWindow
            setupHudWindow(in: windowScene)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
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
