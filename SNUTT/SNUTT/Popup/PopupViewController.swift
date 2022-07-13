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
    let popupView = PopupView()
    var popup: STPopup?

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setButtonActions()
    }

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
        popupView.dismissOnceButton.addTarget(self, action: #selector(dismissOnce), for: .touchUpInside)
        popupView.dismissForNdaysButton.addTarget(self, action: #selector(dismissForNdays), for: .touchUpInside)
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
                    self.popupView.imageView.image = UIImage(data: data)
                    completion()
                }
            }
            task.resume()
        }
    }
}
