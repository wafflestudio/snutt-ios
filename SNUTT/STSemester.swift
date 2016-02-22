//
//  STSemester.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STSemester : Int {
    case First = 1, Summer, Second, Winter
    
    static let allValues = [First, Summer, Second, Winter]
    
    func shortString() -> String {
        switch self {
        case First: return "1"
        case Second: return "2"
        case Summer: return "S"
        case Winter: return "W"
        }
    }
    func longString() -> String {
        switch self {
        case First: return NSLocalizedString("first_semester", comment: "")
        case Second: return NSLocalizedString("second_semester", comment: "")
        case Summer: return NSLocalizedString("summer_semester", comment: "")
        case Winter: return NSLocalizedString("winter_semester", comment: "")
        }
    }
}

extension STSemester : Comparable {}

func <<T: RawRepresentable where T.RawValue: Comparable>(a: T, b: T) -> Bool {
    return a.rawValue < b.rawValue
}