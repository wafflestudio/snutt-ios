//
//  STLoginTextField.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 14..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import ChameleonFramework
import UIKit

@IBDesignable
class STLoginTextField: UITextField {
    let lineView = UIView()

    @IBInspectable var lineColor: UIColor = .black {
        didSet {
            setLineView()
        }
    }

    @IBInspectable var lineWidth: CGFloat = 0 {
        didSet {
            setLineView()
        }
    }

    @IBInspectable var lineBelow: CGFloat = 0 {
        didSet {
            setLineView()
        }
    }

    func setLineView() {
        lineView.center = CGPoint(x: frame.midX, y: frame.size.height + lineBelow)
        lineView.frame.size = CGSize(width: frame.size.width, height: lineWidth)
        lineView.backgroundColor = lineColor
    }

    func setup() {
        addSubview(lineView)
        setLineView()
        clipsToBounds = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setLineView()
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
         // Drawing code
     }
     */
}
