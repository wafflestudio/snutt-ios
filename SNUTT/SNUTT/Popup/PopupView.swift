//
//  PopupView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/17.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import UIKit

class PopupView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(imageView)
        addSubview(dismissOnceButton)
        addSubview(divider)
        addSubview(dismissForNdaysButton)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor, constant: -145),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4 / 3), // 4:3 image ratio, scale to fill
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            dismissOnceButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
            dismissOnceButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            dismissOnceButton.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 6 / 23)
        ])
        
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 17),
            divider.trailingAnchor.constraint(equalTo: dismissOnceButton.leadingAnchor, constant: -16),
            divider.centerYAnchor.constraint(equalTo: dismissOnceButton.centerYAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            dismissForNdaysButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            dismissForNdaysButton.centerYAnchor.constraint(equalTo: divider.centerYAnchor),
        ])
    }

    // MARK: View Components

    lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.5)
        return view
    }()

    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.backgroundColor = .white
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    private func createDismissButton(text: String) -> UIButton {
        let button = UIButton()
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
        return button
    }

    lazy var dismissOnceButton: UIButton = createDismissButton(text: "닫기")

    lazy var dismissForNdaysButton: UIButton = createDismissButton(text: "다시 보지 않기")
}
