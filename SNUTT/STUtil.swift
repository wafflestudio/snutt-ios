//
//  STUtil.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

class STUtil {
    static func getRangeFromNSRange(string : String, range : NSRange) -> Range<String.Index>{
        let startIndex = string.startIndex.advancedBy(range.location)
        let endIndex = startIndex.advancedBy(range.length)
        return Range(start: startIndex, end: endIndex)
    }
}

extension String {
    func localizedString() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UIView {
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
}