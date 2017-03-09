//
//  STColor.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 2..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

struct STColor {
    static let colorList = [
        STColor(fgHex: "#2B8728", bgHex: "#B6F9B2"),
        STColor(fgHex: "#45B2B8", bgHex: "#BFF7F8"),
        STColor(fgHex: "#1579C2", bgHex: "#94E6FE"),
        STColor(fgHex: "#A337A1", bgHex: "#FFCFFF"),
        STColor(fgHex: "#B8991B", bgHex: "#FFF49A"),
        STColor(fgHex: "#BA313B", bgHex: "#FFC9D0"),
        STColor(fgHex: "#649624", bgHex: "#DAF9B2"),
        STColor(fgHex: "#5249D7", bgHex: "#DBD9FD"),
        STColor(fgHex: "#E27B35", bgHex: "#FFDAB7") ]
    
    static let colorNameList = ["초록색", "하늘색", "파랑색", "보라색", "노랑색", "빨강색", "라임색", "남색", "오렌지색"]
    
    var fgColor : UIColor
    var bgColor : UIColor
    
    init() {
        fgColor = UIColor(hexString: "#333333")
        bgColor = UIColor(hexString: "#E0E0E0")
    }
    
    init(fgHex : String, bgHex : String) {
        fgColor = UIColor(hexString: fgHex)
        bgColor = UIColor(hexString: bgHex)
    }
}

extension STColor : Equatable {}

func == (lhs : STColor, rhs : STColor) -> Bool  {
    return lhs.fgColor.toHexString() == rhs.fgColor.toHexString() &&
        lhs.bgColor.toHexString() == rhs.bgColor.toHexString()
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }
}
