//
//  STFCMInfoList.swift
//  SNUTT
//
//  Created by Rajin on 2017. 10. 9..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

class STFCMInfoList : NSObject, NSCoding {
    var infoList : [STFCMInfo] = []

    init(infoList: [STFCMInfo]) {
        self.infoList = infoList
    }

    func encode(with coder: NSCoder) {
        coder.encode(infoList, forKey: "infoList")
    }

    required convenience init?(coder decoder: NSCoder) {
        if let tmp = decoder.decodeObject(forKey: "infoList") as? [STFCMInfo] {
            self.init(infoList: tmp)
        } else {
            self.init(infoList: [])
        }
    }
}
