//
//  STLoginTextField.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 14..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STLoginTextField: UITextField {
    
    let lineColor : UIColor = HexColor("#FFFFFF", 0.6)!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textColor = UIColor(white: 1.0, alpha: 1.0)
        self.setBottomBorder(lineColor, width: 1.0)
    }
    
    override func drawPlaceholder(in rect: CGRect) {
        let placeholderRect = CGRect(x: rect.origin.x, y: (rect.height - self.font!.pointSize)/2, width: rect.width, height: self.font!.pointSize)
        
        let attribute : [String : AnyObject] = [NSForegroundColorAttributeName : lineColor]
        NSString(string: self.placeholder!).draw(in: placeholderRect, withAttributes: attribute)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
