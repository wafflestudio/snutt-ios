//
//  STSingleClass.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

struct STSingleClass {
    var time : STTime
    var place : String
    
    init(time : STTime, place: String) {
        self.time = time
        self.place = place
    }
    
    func toDictionary() -> [String: Any] {
        let dict : [String: Any] = [
            "day" : time.day.rawValue,
            "start" : time.startPeriod,
            "len" : time.duration,
            "place" : place
        ]
        return dict
    }
    
}

extension STSingleClass : Equatable {}

func ==(lhs: STSingleClass, rhs: STSingleClass) -> Bool {
    return lhs.time == rhs.time && lhs.place == rhs.place
}
