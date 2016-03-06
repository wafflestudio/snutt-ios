//
//  STTagList.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STTagList : NSObject, NSCoding {
    var quarter : STQuarter
    var tagList : [STTag]
    var updatedTime: String
    init(quarter: STQuarter, tagList: [STTag], updatedTime: String) {
        self.quarter = quarter
        self.tagList = tagList
        self.updatedTime = updatedTime
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(quarter.dictionaryValue(), forKey: "quarter")
        coder.encodeObject(tagList.dictionaryValue(), forKey: "tagList")
        coder.encodeObject(updatedTime, forKey: "updatedTime")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let quarter = STQuarter(dictionary: decoder.decodeObjectForKey("quarter") as? NSDictionary),
        let tagList = [STTag](dictionary: decoder.decodeObjectForKey("tagList") as? [NSDictionary]),
            let updatedTime = decoder.decodeObjectForKey("updatedTime") as? String else {
            return nil
        }
        self.init(quarter: quarter, tagList: tagList, updatedTime: updatedTime)
    }
}