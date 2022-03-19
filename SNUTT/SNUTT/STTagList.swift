//
//  STTagList.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STTagList: NSObject, NSCoding {
    var quarter: STQuarter
    var tagList: [STTag]
    var updatedTime: Int64
    init(quarter: STQuarter, tagList: [STTag], updatedTime: Int64) {
        self.quarter = quarter
        self.tagList = tagList

        let englishTag: EtcTag = .english
        let armyTag: EtcTag = .army
        let emptyTag: EtcTag = .empty

        let otherTagList: [STTag] = [STTag(type: .Etc, text: emptyTag.rawValue), STTag(type: .Etc, text: englishTag.rawValue), STTag(type: .Etc, text: armyTag.rawValue)]

        if !tagList.contains(otherTagList[0]) {
            self.tagList = tagList + otherTagList
        }

        self.updatedTime = updatedTime
    }

    func encode(with coder: NSCoder) {
        coder.encode(quarter.dictionaryValue(), forKey: "quarter")
        coder.encode(tagList.dictionaryValue(), forKey: "tagList")
        coder.encode(updatedTime, forKey: "updatedTime")
    }

    required convenience init?(coder decoder: NSCoder) {
        guard let quarter = STQuarter(dictionary: decoder.decodeObject(forKey: "quarter") as? NSDictionary),
              let tagList = [STTag](dictionary: decoder.decodeObject(forKey: "tagList") as? [NSDictionary])
        else {
            return nil
        }
        let updatedTime = decoder.decodeInt64(forKey: "updatedTime")

        self.init(quarter: quarter, tagList: tagList, updatedTime: updatedTime)
    }
}

enum EtcTag: String {
    case empty = "빈 시간대"
    case english = "영어진행 강의"
    case army = "군휴학 원격수업"

    func convertToAbb() -> String {
        switch self {
        case .empty:
            return ""
        case .english:
            return "E"
        case .army:
            return "MO"
        }
    }
}
