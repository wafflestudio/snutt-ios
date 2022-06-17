//
//  PopUpView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/17.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import UIKit

class PopUpView: UIView {
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
        backgroundColor = .black.withAlphaComponent(0.5)

        addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            vstack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -120),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4 / 3) // 4:3 image ratio, scale to fill
        ])
    }

    // MARK: View Components

    lazy var hstack: UIStackView = {
        let hstack = UIStackView(arrangedSubviews: [dismissForNdaysButton, divider, dismissOnceButton])
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 17),
        ])
        hstack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        hstack.isLayoutMarginsRelativeArrangement = true
        hstack.axis = .horizontal
        hstack.distribution = .fillProportionally
        hstack.spacing = 10
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()

    lazy var vstack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [imageView, hstack])
        vstack.axis = .vertical
        vstack.spacing = 10
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()

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
