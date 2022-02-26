//
//  STFCMInfo.swift
//  SNUTT
//
//  Created by Rajin on 2017. 10. 9..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

@objc(STFCMInfo)
class STFCMInfo : NSObject, NSCoding {

    var userId : String = ""
    var fcmToken : String = ""

    init(userId: String, fcmToken: String) {
        self.userId = userId
        self.fcmToken = fcmToken
    }

    func encode(with coder: NSCoder) {
        coder.encode(userId, forKey: "userId")
        coder.encode(fcmToken, forKey: "fcmToken")
    }

    required convenience init?(coder decoder: NSCoder) {
        if let userId = decoder.decodeObject(forKey: "userId") as? String, let fcmToken = decoder.decodeObject(forKey: "fcmToken") as? String {
            self.init(userId: userId, fcmToken: fcmToken)
        } else {
            self.init(userId: "", fcmToken: "")
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? STFCMInfo {
            return userId == object.userId && fcmToken == object.fcmToken
        } else {
            return false
        }
    }

    override var hash: Int {
        return userId.hashValue * 31 + fcmToken.hashValue
    }
}
