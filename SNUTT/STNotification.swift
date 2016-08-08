//
//  STNotification.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol STNotification {
    var message: String { get }
    var createdTime: String { get }
    var type: Int { get }
}

class STNotiUtil {
    static func parse(json: JSON) -> STNotification {
        switch json["type"].intValue {
        case 0:
            return STNormalNotification(json: json)
        case 1:
            return STCourseBookNotification(json: json)
        case 2:
            return STLectureNotification(json: json)
        default:
            return STNormalNotification(json: json)
        }
    }
}

struct STNormalNotification : STNotification {
    let message: String
    let createdTime: String
    let type: Int = 0
    init(json : JSON) {
        message = json["message"].stringValue
        createdTime = json["created_at"].stringValue
    }
}

struct STCourseBookNotification : STNotification {
    let message: String
    let createdTime: String
    let type: Int = 1
    init(json : JSON) {
        message = json["message"].stringValue
        createdTime = json["created_at"].stringValue
    }
}

struct STLectureNotification : STNotification {
    let message: String
    let createdTime: String
    let type: Int = 2
    init(json : JSON) {
        message = json["message"].stringValue
        createdTime = json["created_at"].stringValue
    }
}