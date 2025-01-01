//
//  AnimationHandlerOptions.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import UIKit
import SwiftUI

public struct AnimationHandlerOptions: Sendable {
    typealias AnimationHandler = @Sendable @MainActor (AnimatableUIButton, UIControl.Event) -> Void
    let handler: AnimationHandler

    public static var identity: Self {
        .init { _, _ in }
    }

    public static func scale(_ scale: CGFloat) -> Self {
        .identity.scale(scale)
    }

    public static func backgroundColor(touchDown: Color, touchUp: Color = .clear) -> Self {
        .identity.backgroundColor(touchDown: touchDown, touchUp: touchUp)
    }

    public static func impact() -> Self {
        .identity.impact()
    }

    public func scale(_ scale: CGFloat) -> Self {
        .init { button, event in
            handler(button, event)
            switch event {
            case .touchDown:
                button.transform = .init(scaleX: scale, y: scale)
            case .touchUpInside, .touchUpOutside, .touchCancel:
                button.transform = .identity
            default:
                return
            }
        }
    }

    public func backgroundColor(touchDown: Color, touchUp: Color = .clear) -> Self {
        .init { button, event in
            handler(button, event)
            button.configuration?.background.customView = button.configuration?.background.customView ?? UIView()
            switch event {
            case .touchDown:
                button.configuration?.background.customView?.backgroundColor = UIColor(touchDown)
            case .touchUpInside, .touchUpOutside, .touchCancel:
                button.configuration?.background.customView?.backgroundColor = UIColor(touchUp)
            default:
                return
            }
        }
    }

    public func impact() -> Self {
        .init { button, event in
            handler(button, event)
            switch event {
            case .touchDown:
                button.feedbackGenerator.selectionChanged()
            default:
                return
            }
        }
    }
}
