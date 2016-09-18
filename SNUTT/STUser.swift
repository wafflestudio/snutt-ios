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

class STUser {
    var localId : String?
    var fbId : String?
    var email : String?
    
    static var currentUser: STUser? = STUser(localId: nil, fbId: nil);
    
    static func saveData() {
        if currentUser?.fbId != nil {
            NSUserDefaults.standardUserDefaults().setObject(currentUser?.fbId, forKey: "UserFBId")
        }
        if currentUser?.localId != nil {
            NSUserDefaults.standardUserDefaults().setObject(currentUser?.localId, forKey: "UserLocalId")
        }
    }
    
    static func loadData() {
        if let fbId = NSUserDefaults.standardUserDefaults().objectForKey("UserFBId") as? String {
            currentUser?.fbId = fbId
        }
        if let localId = NSUserDefaults.standardUserDefaults().objectForKey("UserLocalId") as? String {
            currentUser?.localId = localId
        }
    }
    
    static func getUser() {
        let request = Alamofire.request(STUserRouter.GetUser);
        request.responseWithDone({ statusCode, json in
            STUser.currentUser = STUser(json: json)
            STEventCenter.sharedInstance.postNotification(event: STEvent.UserUpdated, object: nil);
            }, failure: { err in
                //FIXME : What to do?
        })
    }
    
    static func logOut() {
        loadLoginPage()
    }
    
    static func loadLoginPage() {
        STUser.currentUser = nil
        STDefaults[.token] = nil
        UIApplication.sharedApplication().delegate?.window??.rootViewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
    }
    
    init(json: JSON) {
        self.localId = json["local_id"].string
        self.fbId = json["fb_id"].string
        self.email = json["email"].string
        
    }
    
    init(localId : String?, fbId : String?) {
        self.localId = localId
        self.fbId = fbId
    }
    
    func isLogined() -> Bool {
        return localId != nil || fbId != nil
    }
    
}
