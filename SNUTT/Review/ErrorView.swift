//
//  ErrorView.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/01/21.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import UIKit

protocol ErrorViewDelegate: AnyObject {
    func retry(_: ErrorView)
}

class ErrorView: UIView {
    
    weak var delegate: ErrorViewDelegate?

    @IBOutlet weak var retryButton: UIButton! {
        didSet {
            retryButton.layer.cornerRadius = 8
            retryButton.contentVerticalAlignment = .center
        }
    }
    
    @IBAction func retry(_ sender: UIButton) {
        delegate?.retry(self)
    }
}
