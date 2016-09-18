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
    var fbName : String?
    var email : String?
    
    static var currentUser: STUser? = nil
    
    static func saveData() {
        if currentUser?.fbName != nil {
            NSUserDefaults.standardUserDefaults().setObject(currentUser?.fbName, forKey: "UserFBName")
        }
        if currentUser?.localId != nil {
            NSUserDefaults.standardUserDefaults().setObject(currentUser?.localId, forKey: "UserLocalId")
        }
    }
    
    static func loadData() {
        if let fbName = NSUserDefaults.standardUserDefaults().objectForKey("UserFBName") as? String {
            currentUser?.fbName = fbName
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
        //TODO : Delete Device ID
        loadLoginPage()
    }
    
    static func loadLoginPage() {
        STUser.currentUser = nil
        STDefaults[.token] = nil
        STDefaults[.isFCMRegistered] = false;
        UIApplication.sharedApplication().delegate?.window??.rootViewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
    }
    
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
    
}
