//
//  AnimatableButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
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
        let customView = button.configuration?.background.customView
        var newConfig = configuration(button)
        newConfig.background.customView = customView
        button.configuration = newConfig
    }
}

public class AnimatableUIButton: UIButton {
    private let animationOptions: AnimationHandlerOptions
    lazy var feedbackGenerator = UISelectionFeedbackGenerator()

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

#Preview(traits: .defaultLayout) {
    let button = AnimatableUIButton(animationOptions: .identity.scale(0.8))
    button.configuration = .plain()
    button.configuration?.image = UIImage(systemName: "button.horizontal.top.press")
    button.setTitleColor(.black, for: .normal)
    return button
}

#Preview {
    PreviewView()
}

private struct PreviewView: View {
    @State var binding = 0

    var body: some View {
        VStack {
            AnimatableButton(
                animationOptions: .identity.scale(0.8).backgroundColor(touchDown: .black.opacity(0.1), touchUp: .clear)
            ) {
                binding += 1
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
