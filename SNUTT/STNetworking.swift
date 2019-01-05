//
//  STNetworking.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase

class STNetworking {
    //MARK: LectureRouter
    
    static func updateLecture(_ timetable: STTimetable, oldLecture: STLecture, newLecture: STLecture, done: @escaping (STTimetable)->(), failure: @escaping ()->()) {
        let request = Alamofire.request(STLectureRouter.updateLecture(timetableId: timetable.id!, oldLecture: oldLecture, newLecture : newLecture))
        request.responseWithDone({ statusCode, json in
            done(STTimetable(json: json))
            }, failure: { _ in
                failure()
            }, showNetworkAlert: true, alertTitle: "강좌 수정 실패"
        )
    }
    
    //MARK: CourseBookRouter
    
    static func getSyllabus(_ quarter: STQuarter, lecture: STLecture, done: @escaping (String)->(), failure: (()->())?) {
        let request = Alamofire.request(STCourseBookRouter.syllabus(quarter: quarter, lecture: lecture))
        request.responseWithDone({ statusCode, json in
            let url = json["url"].stringValue
            done(url)
            }, failure: { _ in
                failure?()
        }, showNetworkAlert: false, showAlert: false)

    }
    
    //MARK: UserRouter

    static func detachFB(_ done: @escaping ()->(), failure: @escaping ()->()) {
        let request = Alamofire.request(STUserRouter.detachFB)
        request.responseWithDone({ _, json in
            STDefaults[.token] = json["token"].stringValue
            done()
            }, failure: { _ in
                failure()
        })
    }
    
    static func attachFB(fb_id: String, fb_token: String, done: @escaping ()->(), failure: @escaping ()->()) {
        let request = Alamofire.request(STUserRouter.addFB(id: fb_id, token: fb_token))
        request.responseWithDone({ _, json in
            if let token = json["token"].string {
                STDefaults[.token] = token
            }
            done()
            }, failure: { _ in
                failure()
        })
    }
    
    static func unregister(_ failure: @escaping ()->()) {
        let request = Alamofire.request(STUserRouter.deleteUser)
        request.responseWithDone({ _, json in
            // TODO: Not proper DI, but still works..
            AppContainer.resolver.resolve(STUserManager.self)!.loadLoginPage()
            }, failure: { _ in
                failure()
        })
    }
    
    static func addDevice(_ deviceId : String) {
        let request = Alamofire.request(STUserRouter.addDevice(id: deviceId))
        if let token = InstanceID.instanceID().token(), let userId = STDefaults[.userId] {
            let fcmInfo = STFCMInfo(userId: userId, fcmToken: token)
            let infos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
            STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: infos.filter( { info in info != fcmInfo}))
        }

        request.responseWithDone({ statusCode, json in
            STDefaults[.registeredFCMToken] = deviceId
            }, failure: nil
            , showNetworkAlert: false
        )
    }

    //MARK: AppVersion
    
    static func checkLatestAppVersion(_ done:@escaping (String)->()) -> Void {
        
        let requestURL = "http://itunes.apple.com/kr/lookup?bundleId=" + Bundle.main.bundleIdentifier!

        Alamofire.request(requestURL, method: .post).responseSwiftyJSON { response in
            switch response.result {
            case .success(let json):
                let version = json["results"].array?.first?["version"].string
                if version == nil {
                    fallthrough
                }
                done(version!)
            case .failure:
                break
            }
        }
    }

    //MARK: Others


    static func showNetworkError() {
        let alert = UIAlertController(title: "Network Error", message: "네트워크 환경이 원활하지 않습니다.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
        UIApplication.shared.keyWindow!.rootViewController!.present(alert, animated: true, completion: nil)
    }

}
