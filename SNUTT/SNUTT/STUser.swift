//
//  STUser.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Crashlytics
import FBSDKLoginKit
import Firebase
import Foundation
import SwiftyJSON
import UIKit

class STUser {
    var localId: String?
    var fbName: String?
    var email: String?

    static var currentUser: STUser?

    static func saveData() {
        if currentUser?.fbName != nil {
            UserDefaults.standard.set(currentUser?.fbName, forKey: "UserFBName")
        }
        if currentUser?.localId != nil {
            UserDefaults.standard.set(currentUser?.localId, forKey: "UserLocalId")
        }
    }

    static func loadData() {
        if let fbName = UserDefaults.standard.object(forKey: "UserFBName") as? String {
            currentUser?.fbName = fbName
        }
        if let localId = UserDefaults.standard.object(forKey: "UserLocalId") as? String {
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
        var fcmInfos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
        if let token = InstanceID.instanceID().token(), let userId = STDefaults[.userId] {
            let fcmInfo = STFCMInfo(userId: userId, fcmToken: token)
            fcmInfos.append(fcmInfo)

            STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: fcmInfos)

            DispatchQueue.main.async {
                STNetworking.logOut(userId: userId, fcmToken: token, done: {
                    let infos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
                    STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: infos.filter { info in info != fcmInfo })
                }, failure: nil)
                loadLoginPage()
            }
        } else {
            loadLoginPage()
        }
    }

    static func loadLoginPage() {
        STUser.currentUser = nil
        STDefaults[.token] = nil
        STDefaults[.userId] = nil
        #if DEBUG
        #else
            Crashlytics.sharedInstance().setUserIdentifier(nil)
        #endif
        STDefaults[.registeredFCMToken] = nil
        STDefaults[.shouldShowBadge] = false
        UIApplication.shared.delegate?.window??.rootViewController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()
    }

    static func loadMainPage() {
        let openController: () -> Void = {
            if let deviceId = InstanceID.instanceID().token() {
                STNetworking.addDevice(deviceId)
            }
            let appDelegate = UIApplication.shared.delegate!
            let window = appDelegate.window!!
            let mainController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            window.rootViewController = mainController
        }

        STNetworking.getRecentTimetable({ timetable in
            STTimetableManager.sharedInstance.currentTimetable = timetable
            openController()
        }, failure: {
            openController()
        })
    }

    static func tryFBLogin(controller: UIViewController) {
        let done: (String, String) -> Void = { token, userId in
            STDefaults[.token] = token
            STDefaults[.userId] = userId
            STUser.loadMainPage()
        }

        let registerFB: (String, String) -> Void = { id, token in
            STNetworking.registerFB(id, token: token, done: done, failure: {})
        }

        if let accessToken = FBSDKAccessToken.current() {
            if let id = accessToken.userID,
               let token = accessToken.tokenString
            {
                registerFB(id, token)
            } else {
                STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
            }
        } else {
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["public_profile"], from: controller, handler: { result, error in
                if error != nil {
                    STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                } else {
                    if let result = result {
                        if result.isCancelled {
                            STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                        } else {
                            let id = result.token.userID!
                            let token = result.token.tokenString!
                            registerFB(id, token)
                        }
                    } else {
                        STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                    }
                }
            })
        }
    }

    static func updateDeviceIdIfNeeded() {
        guard let refreshedToken = InstanceID.instanceID().token() else {
            return
        }
        #if DEBUG
        #else
            if STDefaults[.token] != nil && STDefaults[.registeredFCMToken] != refreshedToken {
                STNetworking.addDevice(refreshedToken)
            }
        #endif
    }

    init(json: JSON) {
        localId = json["local_id"].string
        fbName = json["fb_name"].string
        email = json["email"].string
    }

    init(localId: String?, fbName: String?) {
        self.localId = localId
        self.fbName = fbName
    }

    func isLogined() -> Bool {
        return localId != nil || fbName != nil
    }
}

// MARK: - Apple Login

extension STUser {
    static func tryAppleLogin(token: String) {
        let done: (String, String) -> Void = { token, userId in
            STDefaults[.token] = token
            STDefaults[.userId] = userId
            STUser.loadMainPage()
        }

        STNetworking.registerApple(token: token, done: done, failure: {
            STAlertView.showAlert(title: "로그인 실패", message: "애플 로그인에 실패했습니다.")
        })
    }
}
