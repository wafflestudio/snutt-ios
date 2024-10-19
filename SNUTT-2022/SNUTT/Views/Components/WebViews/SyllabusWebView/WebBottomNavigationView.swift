//
//  WebBottomNavigationView.swift
//  SNUTT
//
//  Created by 박신홍 on 10/19/24.
//

import Combine
import UIKit

final class WebBottomNavigationView: UIView {
    private var buttons = [ButtonType: UIButton]()
    func button(for type: ButtonType) -> UIButton {
        buttons[type]!
    }

    var buttonDidPressPublisher = PassthroughSubject<ButtonType, Never>()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        setupButtons()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let progressView = WebProgressView()

    private func setupView() {
        addSubview(backgroundView)
        addSubview(horizontalButtonView)
        addSubview(progressView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        horizontalButtonView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
            horizontalButtonView.topAnchor.constraint(equalTo: topAnchor),
            horizontalButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor),
        ])
    }

    private let backgroundView: UIView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        let divider = UIView()
        divider.backgroundColor = .label.withAlphaComponent(0.1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: blurView.topAnchor),
            divider.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
        ])
        return blurView
    }()

    private let horizontalButtonView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private func setupButtons() {
        for buttonType in ButtonType.allCases {
            let button = makeButton(for: buttonType)
            buttons[buttonType] = button
            button.addAction { [weak self] in
                self?.buttonDidPressPublisher.send(buttonType)
            }
            horizontalButtonView.addArrangedSubview(button)
        }
    }

    private func makeButton(for type: ButtonType) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = type.image
        let button = UIButton(configuration: config)
        return button
    }
}

extension WebBottomNavigationView {
    enum ButtonType: CaseIterable {
        case back
        case forward
        case reload
        case safari

        var image: UIImage? {
            switch self {
            case .back:
                UIImage(systemName: "chevron.backward")
            case .forward:
                UIImage(systemName: "chevron.forward")
            case .reload:
                UIImage(systemName: "arrow.clockwise")
            case .safari:
                UIImage(systemName: "safari")
            }
        }
    }
}
