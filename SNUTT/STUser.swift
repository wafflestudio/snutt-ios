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
        STNetworking.getUser({ user in
            STUser.currentUser = user
            STEventCenter.sharedInstance.postNotification(event: STEvent.UserUpdated, object: nil)
            }, failure: nil)
    }
    
    static func logOut() {
        if let token = FIRInstanceID.instanceID().token() {
            STNetworking.deleteDevice(token, done: {
                loadLoginPage()
            })
        } else {
            loadLoginPage()
        }
    }
    
    static func loadLoginPage() {
        STUser.currentUser = nil
        STDefaults[.token] = nil
        STDefaults[.isFCMRegistered] = false
        STDefaults[.shouldShowBadge] = false
        UIApplication.sharedApplication().delegate?.window??.rootViewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
    }
    
    static func updateDeviceIdIfNeeded() {
        guard let refreshedToken = FIRInstanceID.instanceID().token() else {
            return
        }
        if (STDefaults[.token] != nil && !STDefaults[.isFCMRegistered]) {
            STNetworking.addDevice(refreshedToken)
        }
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
