//
//  STNotification.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

struct STNotification {
    var category : Int
    var body : String
    
    init(json: JSON) {
        category = json["category"].intValue
        body = json["body"].stringValue
    }
    
    init(category: Int, body: String) {
        self.category = category
        self.body = body
    }
}