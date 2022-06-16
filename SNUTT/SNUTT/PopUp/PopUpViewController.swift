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
        self.view.addSubview(popUpView)
        NSLayoutConstraint.activate([
            popUpView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            popUpView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            popUpView.topAnchor.constraint(equalTo: self.view.topAnchor),
            popUpView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setButtonActions() {
        popUpView.dismissOnceButton.addTarget(self, action: #selector(dismissOnce), for: .touchUpInside)
        popUpView.dismissForNdaysButton.addTarget(self, action: #selector(dismissForNdays), for: .touchUpInside)
    }
    
    @objc func dismissOnce() {
        self.remove()
    }
    
    @objc func dismissForNdays() {
        // TODO: check UserDefaults
        self.remove()
    }
    
    func presentIfNeeded() {
        delegate?.present()
    }
}


extension UIViewController {
    /// `child`를 `self`의 자식 뷰 컨트롤러로 추가한다.
    func add(childVC: UIViewController) {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
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
