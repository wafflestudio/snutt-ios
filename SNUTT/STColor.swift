//
//  STColor.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 2..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import ChameleonFramework

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
        fgColor = HexColor("#333333")
        bgColor = HexColor("#E0E0E0")
    }
    
    init(fgHex : String, bgHex : String) {
        fgColor = HexColor(fgHex)
        bgColor = HexColor(bgHex)
    }
}

extension STColor : Equatable {}

func == (lhs : STColor, rhs : STColor) -> Bool  {
    return lhs.fgColor.hexValue() == rhs.fgColor.hexValue() &&
        lhs.bgColor.hexValue() == rhs.bgColor.hexValue()
}

