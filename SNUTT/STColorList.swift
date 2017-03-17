//
//  STColorList.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 17..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation


class STColorList : NSObject, NSCoding {

    var colorList : [STColor] = []
    var nameList : [String] = []

    init(colorList: [STColor], nameList: [String]) {
        if (colorList.count != nameList.count || colorList.count == 0) {
            self.colorList = [STColor()]
            self.nameList = ["회색"]
        } else {
            self.colorList = colorList
            self.nameList = nameList
        }
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(colorList.dictionaryValue(), forKey: "colorList")
        coder.encodeObject(nameList, forKey: "nameList")
    }

    required convenience init?(coder decoder: NSCoder) {
        guard let colorList = [STColor](dictionary: decoder.decodeObjectForKey("colorList") as? [NSDictionary]),
            let nameList = decoder.decodeObjectForKey("nameList") as? [String] else {
                return nil
        }
        self.init(colorList: colorList, nameList: nameList)
    }
    
}
