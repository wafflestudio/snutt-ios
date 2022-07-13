//
//  PopupViewController.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/17.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import UIKit

protocol PopupViewControllerDelegate: class {
    func present(viewController: PopupViewController)
    func dismiss()
    func dismissForNdays()
    func setNewCurrentPopup()
}

class PopupViewController: UIViewController {
    var delegate: PopupViewControllerDelegate?
    let popupView = UIView()
    var popup: STPopup?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setLayout()
        setButtonActions()
    }
    
    private func setupView() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.backgroundColor = .clear

        popupView.addSubview(imageView)
        popupView.addSubview(dismissOnceButton)
        popupView.addSubview(divider)
        popupView.addSubview(dismissForNdaysButton)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: popupView.widthAnchor, constant: -145),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 4 / 3), // 4:3 image ratio, scale to fill
            imageView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: popupView.centerYAnchor)
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

    lazy var dismissForNdaysButton: UIButton = createDismissButton(text: { () -> String in
        guard let hiddenDays = popup?.hiddenDays else {
            return "다시 보지 않기"
        }
        if hiddenDays == 0 {
            return "다시 보지 않기"
        } else {
            return "\(hiddenDays)일 보지 않기"
        }
    }())

    private func setLayout() {
        view.addSubview(popupView)
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popupView.topAnchor.constraint(equalTo: view.topAnchor),
            popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setButtonActions() {
        dismissOnceButton.addTarget(self, action: #selector(dismissOnce), for: .touchUpInside)
        dismissForNdaysButton.addTarget(self, action: #selector(dismissForNdays), for: .touchUpInside)
    }

    @objc func dismissOnce() {
        self.delegate?.dismiss()
    }

    @objc func dismissForNdays() {
        // TODO: check UserDefaults
        self.delegate?.dismissForNdays()
    }

    func presentIfNeeded(popup: STPopup, at viewController: PopupViewController) {
        guard let url = popup.imageURL else { return }
        loadPopUpImage(url: url) {
            self.delegate?.present(viewController: viewController)
        }
    }
    
    func loadPopUpImage(url: String, completion: @escaping () -> Void) {
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                    completion()
                }
            }
            task.resume()
        }
    }
}
