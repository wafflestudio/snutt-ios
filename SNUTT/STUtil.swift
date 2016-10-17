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
    
    static func validateEmail(candidate: String) -> Bool {
        // from http://emailregex.com
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    static func validatePassword(password: String) -> Bool {
        if let _ = password.rangeOfString("^(?=.*\\d)(?=.*[a-z])\\S{6,20}$", options: [.RegularExpressionSearch, .CaseInsensitiveSearch]) {
            return true
        }
        return false
    }
    
    static func validateId(id: String) -> Bool {
        if let _ = id.rangeOfString("^[a-z0-9]{4,32}$", options: [.RegularExpressionSearch, .CaseInsensitiveSearch]) {
            return true
        }
        return false
    }
}

extension String {
    func localizedString() -> String {
        return NSLocalizedString(self, comment: "")
    }
    var breakOnlyAtNewLineAndSpace : String {
        let sc : Character = "\u{FEFF}"
        var tmp : [Character] = []
        var words : [String] = []
        for (index, ch) in self.characters.enumerate() {
            if ch == "\n" || ch == " " {
                words.append(String(tmp))
                words.append(String(ch))
                tmp = []
            } else {
                tmp.append(ch)
            }
        }
        if tmp.count != 0 {
            words.append(String(tmp))
        }
        
        let ret = words.map({ (word: String) -> (String) in
            var tmp : [Character] = []
            for (index, ch) in word.characters.enumerate() {
                tmp.append(ch)
                tmp.append(sc)
            }
            tmp.popLast()
            return String(tmp)
        })
        
        return ret.joinWithSeparator("")
    }
}

extension UIView {
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
    func roundCorner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func setBottomBorder(color: UIColor, width: Double)
    {
        let border = CALayer()
        let width = CGFloat(width)
        border.borderColor = color.CGColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func mask(rect : CGRect) {
        let maskLayer = CAShapeLayer()
        let path = CGPathCreateWithRect(rect, nil)
        maskLayer.path = path
        self.layer.mask = maskLayer
    }
}

// Protocol for nscoding with struct in swift, source : http://redqueencoder.com/property-lists-and-user-defaults-in-swift/

protocol DictionaryRepresentable {
    func dictionaryValue() -> NSDictionary
    init?(dictionary:NSDictionary?)
}

extension RawRepresentable {
    init?(raw: Self.RawValue?) {
        if let rawValue = raw {
            self.init(rawValue: rawValue)
        } else {
            return nil
        }
    }
}

extension Array where Element : DictionaryRepresentable{
    func dictionaryValue() -> [NSDictionary] {
        let representation : [NSDictionary] = self.map{return $0.dictionaryValue()}
        return representation
    }
    init?(dictionary:[NSDictionary]?) {
        guard let values = dictionary else {return nil}
        var testArray : [Element?] = values.map({return Element(dictionary: $0)})
        let rawArray = testArray.flatMap({ $0 })
        if testArray.count != rawArray.count {
            return nil
        }
        self = rawArray
    }
}

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

