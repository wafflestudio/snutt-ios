//
//  WebBottomNavigationView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Combine
import SnapKit
import UIKit
import UIKitUtility

final class WebBottomNavigationView: UIView {
    private var buttons = [ButtonType: UIButton]()
    let progressView = WebProgressView()
    var buttonDidPressPublisher = PassthroughSubject<ButtonType, Never>()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        setupButtons()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func button(for type: ButtonType) -> UIButton {
        buttons[type]!
    }

    private func setupView() {
        addSubview(backgroundView)
        addSubview(horizontalButtonView)
        addSubview(progressView)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        horizontalButtonView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }

        progressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(backgroundView.snp.top)
        }
    }

    private let backgroundView: UIView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        let divider = UIView()
        divider.backgroundColor = .label.withAlphaComponent(0.1)
        blurView.contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
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
            case .back: UIImage(systemName: "chevron.backward")
            case .forward: UIImage(systemName: "chevron.forward")
            case .reload: UIImage(systemName: "arrow.clockwise")
            case .safari: UIImage(systemName: "safari")
            }
        }
    }
}
