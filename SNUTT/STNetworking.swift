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
    
    //MARK: AuthRouter
    
    static func registerFB(_ id: String, token: String, done: @escaping (String, String)->(), failure: @escaping ()->()) {
        let request = Alamofire.request(STAuthRouter.fbRegister(id: id, token: token))
        request.responseWithDone({ statusCode, json in
            done(json["token"].stringValue, json["user_id"].stringValue)
        }, failure: { err in
            failure()
        })
    }

    static func logOut(userId: String, fcmToken: String, done: @escaping ()->(), failure: (()->())?) {
        let request = Alamofire.request(STAuthRouter.logOutDevice(userId: userId, fcmToken: fcmToken))
        request.responseWithDone({ statusCode, json in
            done()
        }, failure: { err in
            failure?()
        }, showNetworkAlert: false)
    }
    
    //MARK: TimetableRouter
    
    static func createTimetable(_ title: String, courseBook: STCourseBook, done: @escaping ([STTimetable])->(), failure: @escaping ()->()) {
        Alamofire.request(STTimetableRouter.createTimetable(title: title, courseBook: courseBook)).responseWithDone({ statusCode, json in
            let timetables = json.arrayValue
            let timetableList = timetables.map { json in
                return STTimetable(json: json)
            }
            done(timetableList)
            }, failure: { _ in
                failure()
        })
    }

    static func getRecentTimetable(_ done: @escaping (STTimetable?)->(), failure: @escaping ()->()) {
        Alamofire.request(STTimetableRouter.getRecentTimetable())
            .responseWithDone({ statusCode, json in
                done(STTimetable(json: json))
            }, failure: { _ in
                failure()
            })
    }
    
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
    
    static func getCourseBookList(_ done: @escaping ([STCourseBook])->(), failure: @escaping ()->()) {
        let request = Alamofire.request(STCourseBookRouter.get)
        request.responseWithDone({ statusCode, json in
            let list = json.arrayValue.map({ json in
                return STCourseBook(json: json)
            })
            done(list)
            }, failure: { _ in
                failure()
        })
    }
    
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

    static func getUser(_ done: ((STUser)->())?, failure: (()->())?) {
        let request = Alamofire.request(STUserRouter.getUser);
        request.responseWithDone({ statusCode, json in
            done?(STUser(json:json))
            }, failure: { err in
                failure?()
        })
    }

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
            STUser.loadLoginPage()
            }, failure: { _ in
                failure()
        })
    }
    
    static func editUser(_ email: String, done: @escaping ()->(), failure: @escaping ()->()) {
        let request = Alamofire.request(STUserRouter.editUser(email: email))
        request.responseWithDone({ _, _ in
            done()
            }, failure: { _ in
                failure()
        })
    }
    
    static func changePassword(_ curPassword: String, newPassword: String, done: @escaping () -> (), failure: @escaping (String?)->()) {
        let request = Alamofire.request(STUserRouter.changePassword(oldPassword: curPassword, newPassword: newPassword))
        request.responseWithDone({ statusCode, json in
            if let token = json["token"].string {
                STDefaults[.token] = token
            }
            done()
            }, failure: { _ in
                failure(nil)
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
    
    static func deleteDevice(_ deviceId : String, done: @escaping ()->()) {
        let request = Alamofire.request(STUserRouter.deleteDevice(id: deviceId))
        request.responseWithDone({ statusCode, json in
            done()
            }, failure: nil, showNetworkAlert: true
        )
    }
    
    static func addLocalID(_ id: String, password: String, done: @escaping ()->()) {
        let request = Alamofire.request(STUserRouter.addLocalId(id: id, password: password))
        request.responseWithDone({statusCode, json in
            if let token = json["token"].string {
                STDefaults[.token] = token
            }
            STUser.getUser()
            done()
        }, failure: nil)
    }
    
    //MARK: STEtcRouter

    static func sendFeedback(_ email: String?, message: String, done: (()->())?, failure: (()->())?) {
        let request = Alamofire.request(STEtcRouter.feedback(email: email, message: message))
        request.responseWithDone({ _, _ in
                done?()
        }, failure: { _ in
            failure?()
        })
    }

    static func getColors(_ done: (([STColor], [String])->())?, failure: (()->())?) {
        let request = Alamofire.request(STEtcRouter.getColor)
        request.responseWithDone({ statusCode, json in
            let colors = json["colors"].arrayValue.map { colorJson in STColor(json: colorJson) }
            let names = json["names"].arrayValue.map { it in it.stringValue }
            done?(colors, names)
            }, failure: { _ in
                failure?()
        }, showNetworkAlert: false)
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
