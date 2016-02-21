//
//  STDay.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STDay : Int{
    case MON=0, TUE, WED, THU, FRI, SAT
    
    func shortString() -> String {
        switch self {
        case MON: return NSLocalizedString("monday_short", comment: "")
        case TUE: return NSLocalizedString("tuesday_short", comment: "")
        case WED: return NSLocalizedString("wednesday_short", comment: "")
        case THU: return NSLocalizedString("thursday_short", comment: "")
        case FRI: return NSLocalizedString("friday_short", comment: "")
        case SAT: return NSLocalizedString("saturday_short", comment: "")
        }
    }
    
    func longString() -> String {
        switch self {
        case MON: return NSLocalizedString("monday", comment: "")
        case TUE: return NSLocalizedString("tuesday", comment: "")
        case WED: return NSLocalizedString("wednesday", comment: "")
        case THU: return NSLocalizedString("thursday", comment: "")
        case FRI: return NSLocalizedString("friday", comment: "")
        case SAT: return NSLocalizedString("saturday", comment: "")
        }
    }
}

extension STDay: Comparable {}