//
//  STColor.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 2..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct STColor {
    
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
    
    init(json: JSON) {
        self.init(fgHex: json["fg"].stringValue, bgHex: json["bg"].stringValue)
    }
}

extension STColor : Equatable {}

func == (lhs : STColor, rhs : STColor) -> Bool  {
    return lhs.fgColor.toHexString() == rhs.fgColor.toHexString() &&
        lhs.bgColor.toHexString() == rhs.bgColor.toHexString()
}

extension STColor : DictionaryRepresentable {
    func dictionaryValue() -> NSDictionary {
        return ["fg": self.fgColor.toHexString(), "bg" : self.bgColor.toHexString()]
    }
    
    init?(dictionary: NSDictionary?) {
        guard let values = dictionary else {return nil}
        guard let fg = values["fg"] as? String, let bg = values["bg"] as? String else {
            return nil
        }
        self.fgColor = UIColor(hexString: fg)
        self.bgColor = UIColor(hexString: bg)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
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
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
