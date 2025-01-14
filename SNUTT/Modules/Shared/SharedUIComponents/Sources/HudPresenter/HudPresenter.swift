//
//  HudPresenter.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

@MainActor
public protocol HudPresenterProtocol: Sendable {
    func presentAlert(error: any Error)
}

public class HudPresenter: HudPresenterProtocol {
    private var windowScene: UIWindowScene

    public init?(windowScene: UIWindowScene? = nil) {
        guard let windowScene else { return nil }
        self.windowScene = windowScene
    }

    public func presentAlert(error: any Error) {
        print("error:\(error) window:\(windowScene) localized:\(error.localizedDescription)")
    }
}

public extension EnvironmentValues {
    @Entry var hudPresenter: (any HudPresenterProtocol)?
}
