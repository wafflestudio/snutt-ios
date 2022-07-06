//
//  PopUpViewController.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/17.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import UIKit

protocol PopUpViewControllerDelegate: class {
    func present()
}

class PopUpViewController: UIViewController {
    var delegate: PopUpViewControllerDelegate?
    let popUpView = PopUpView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setButtonActions()
    }

    private func setLayout() {
        view.addSubview(popUpView)
        NSLayoutConstraint.activate([
            popUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popUpView.topAnchor.constraint(equalTo: view.topAnchor),
            popUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setButtonActions() {
        popUpView.dismissOnceButton.addTarget(self, action: #selector(dismissOnce), for: .touchUpInside)
        popUpView.dismissForNdaysButton.addTarget(self, action: #selector(dismissForNdays), for: .touchUpInside)
    }

    @objc func dismissOnce() {
        remove()
    }

    @objc func dismissForNdays() {
        // TODO: check UserDefaults
        remove()
    }

    func presentIfNeeded() {
        print(STPopUpList.sharedInstance)
        let popUpList = STPopUpList.sharedInstance?.popUpList
        guard let popUpList = popUpList else {
            return
        }
        for popup in popUpList {
            guard let url = popup.imageURL else { continue }
            loadPopUpImage(url: url) {
                self.delegate?.present()
            }
        }
    }
    
    func loadPopUpImage(url: String, completion: @escaping () -> Void) {
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async {
                    self.popUpView.imageView.image = UIImage(data: data)
                    completion()
                }
            }

            task.resume()
        }
    }
}

extension UIViewController {
    /// `child`를 `self`의 자식 뷰 컨트롤러로 추가한다.
    func add(childVC: UIViewController, animate: Bool = true) {
        childVC.view.alpha = 0

        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)

        UIView.animate(withDuration: animate ? 0.3 : 0, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: []) {
            childVC.view.alpha = 1
        }
    }

    /// 부모 뷰 컨트롤러로부터 `self`를 제거한다.
    func remove(animate: Bool = true) {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }
        UIView.animate(withDuration: animate ? 0.3 : 0, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: []) {
            self.view.alpha = 0
        } completion: { _ in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
