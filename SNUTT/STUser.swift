//
//  STUser.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import Crashlytics
import FBSDKLoginKit

class STUser: Codable {
    var localId : String?
    var fbName : String?
    var email : String?
    
    init(json: JSON) {
        self.localId = json["local_id"].string
        self.fbName = json["fb_name"].string
        self.email = json["email"].string
        
    }
    
    init(localId : String?, fbName : String?) {
        self.localId = localId
        self.fbName = fbName
    }
    
    func isLogined() -> Bool {
        return localId != nil || fbName != nil
    }

    private enum CodingKeys: String, CodingKey {
        case local_id
        case fb_name
        case email
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(localId, forKey: .local_id)
        try container.encodeIfPresent(fbName, forKey: .fb_name)
        try container.encodeIfPresent(email, forKey: .email)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        localId = try container.decode(String.self, forKey: .local_id)
        fbName = try container.decodeIfPresent(String.self, forKey: .fb_name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
    }
}
