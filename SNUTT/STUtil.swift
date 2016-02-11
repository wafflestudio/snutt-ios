//
//  STUtil.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STUtil {
    static func getRangeFromNSRange(string : String, range : NSRange) -> Range<String.Index>{
        let startIndex = string.startIndex.advancedBy(range.location)
        let endIndex = startIndex.advancedBy(range.length)
        return Range(start: startIndex, end: endIndex)
    }
}