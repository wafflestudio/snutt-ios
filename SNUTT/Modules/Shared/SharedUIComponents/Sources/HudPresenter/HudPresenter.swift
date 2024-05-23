//
//  HudPresenter.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import UIKit
import SwiftUI

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

extension EnvironmentValues {
    @Entry public var hudPresenter: (any HudPresenterProtocol)?
}
