//
//  SceneDelegate.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

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
