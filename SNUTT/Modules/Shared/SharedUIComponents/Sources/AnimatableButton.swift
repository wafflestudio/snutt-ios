//
//  AnimatableButton.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit
import UIKitUtility

public struct AnimatableButton: UIViewRepresentable {
    private let animationOptions: AnimationHandlerOptions
    private let layoutOptions: LayoutOptions
    private let action: () -> Void
    private let configuration: (UIButton) -> UIButton.Configuration

    public init(
        animationOptions: AnimationHandlerOptions = .identity.scale(0.95),
        layoutOptions: LayoutOptions = .default,
        action: @escaping () -> Void,
        configuration: @escaping (UIButton) -> UIButton.Configuration
    ) {
        self.action = action
        self.layoutOptions = layoutOptions
        self.animationOptions = animationOptions
        self.configuration = configuration
    }

    public func makeUIView(context _: Context) -> UIView {
        let button = AnimatableUIButton(animationOptions: animationOptions)
        let view = CenterContainerView(contentView: button, layoutOptions: layoutOptions)
        button.configuration = configuration(button)
        button.addAction {
            action()
        }
        return view
    }

    public func updateUIView(_ uiView: UIView, context _: Context) {
        guard let button = (uiView as? CenterContainerView<AnimatableUIButton>)?.contentView else { return }
        button.configuration = configuration(button)
    }
}

public struct AnimationHandlerOptions: Sendable {
    fileprivate typealias AnimationHandler = @Sendable @MainActor (AnimatableUIButton, UIControl.Event) -> Void
    fileprivate let handler: AnimationHandler

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

public class AnimatableUIButton: UIButton {
    private let animationOptions: AnimationHandlerOptions
    fileprivate lazy var feedbackGenerator = UISelectionFeedbackGenerator()

    public init(
        animationOptions: AnimationHandlerOptions
    ) {
        self.animationOptions = animationOptions
        super.init(frame: .zero)
        addEvents()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addEvents() {
        let events: [UIControl.Event] = [.touchDown, .touchUpInside, .touchUpOutside, .touchCancel]
        for event in events {
            addAction(for: event) { [weak self] in
                self?.animate(for: event)
            }
        }
    }

    private func animate(for event: UIControl.Event) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) { [weak self] in
            guard let self else { return }
            animationOptions.handler(self, event)
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .defaultLayout) {
    let button = AnimatableUIButton(animationOptions: .identity.scale(0.8))
    button.configuration = .plain()
    button.configuration?.image = UIImage(systemName: "button.horizontal.top.press")
    button.setTitleColor(.black, for: .normal)
    return button
}

@available(iOS 17.0, *)
#Preview {
    PreviewView()
}

@available(iOS 17.0, *)
private struct PreviewView: View {
    @State var binding = 0 {
        didSet {
            print(binding)
        }
    }

    var body: some View {
        VStack {
            AnimatableButton(
                animationOptions: .identity.scale(0.8).backgroundColor(touchDown: .black.opacity(0.1), touchUp: .clear)
            ) {
                binding += 1
                print(binding)
            } configuration: { _ in
                var config = UIButton.Configuration.plain()
                if binding % 2 == 0 {
                    config.image = UIImage(systemName: "button.horizontal.top.press")
                } else {
                    config.image = UIImage(systemName: "circle")
                }
                return config
            }
        }
    }
}
