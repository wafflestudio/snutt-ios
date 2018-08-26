//
//  STColorList.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 17..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

@objc(STColorList)
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

    func encode(with coder: NSCoder) {
        coder.encode(colorList.dictionaryValue(), forKey: "colorList")
        coder.encode(nameList, forKey: "nameList")
    }

    required convenience init?(coder decoder: NSCoder) {
        guard let colorList = [STColor](dictionary: decoder.decodeObject(forKey: "colorList") as? [NSDictionary]),
            let nameList = decoder.decodeObject(forKey: "nameList") as? [String] else {
                return nil
        }
        self.init(colorList: colorList, nameList: nameList)
    }
    
}
