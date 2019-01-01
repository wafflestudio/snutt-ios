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
    var place : String {
        didSet {
            placeBreakLine = place.breakOnlyAtNewLineAndSpace
        }
    }
    var placeBreakLine: String

    init(time : STTime, place: String) {
        self.time = time
        self.place = place
        self.placeBreakLine = place.breakOnlyAtNewLineAndSpace
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


extension STSingleClass : Codable {
    private enum CodingKeys: String, CodingKey {
        case day
        case start
        case len
        case place
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time.day.rawValue, forKey: .day)
        try container.encode(time.startPeriod, forKey: .start)
        try container.encode(time.duration, forKey: .len)
        try container.encode(place, forKey: .place)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let day = try container.decode(Int.self, forKey: .day)
        let startPeriod = try container.decode(Double.self, forKey: .start)
        let len = try container.decode(Double.self, forKey: .len)
        time = STTime(day: day, startPeriod: startPeriod, duration : len)
        place = (try? container.decode(String.self, forKey: .place)) ?? ""
        placeBreakLine = place.breakOnlyAtNewLineAndSpace
    }
}

extension STSingleClass : Equatable {}

func ==(lhs: STSingleClass, rhs: STSingleClass) -> Bool {
    return lhs.time == rhs.time && lhs.place == rhs.place
}
