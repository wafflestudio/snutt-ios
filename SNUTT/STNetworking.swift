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

class STNetworking {
    
    //MARK: AuthRouter
    
    static func loginLocal(id: String, password: String, done: (String)->(), failure: ()->()) {
        let request = Alamofire.request(STAuthRouter.LocalLogin(id: id, password: password))
        
        request.responseWithDone({ statusCode, json in
            if statusCode == 200 {
                done(json["token"].stringValue)
            } else {
                failure()
            }
        }, failure: { err in
            failure()
        })
    }
    
    static func registerLocal(id: String, password: String, done: ()->(), failure: ()->()) {
        let request = Alamofire.request(STAuthRouter.LocalRegister(id: id, password: password))
        
        request.responseWithDone({ statusCode, json in
            if (statusCode == 200) {
                done()
            } else {
                failure()
            }
        }, failure: { err in
            failure()
        })
    }
    
    static func registerFB(id: String, token: String, done: (String)->(), failure: ()->()) {
        let request = Alamofire.request(STAuthRouter.FBRegister(id: id, token: token))
        request.responseWithDone({ statusCode, json in
            if (statusCode == 200) {
                done(json["token"].stringValue)
            } else {
                failure()
            }
        }, failure: { err in
            failure()
        })
    }
    
    //MARK: TimetableRouter
    
    static func getTimetableList(done: ([STTimetable])->(), failure: ()->()) {
        Alamofire.request(STTimetableRouter.GetTimetableList).responseWithDone({ statusCode, json in
            let timetables = json.arrayValue
            let timetableList = timetables.map { json in
                return STTimetable(json: json)
            }
            done(timetableList)
            }, failure: { _ in
                failure()
        })
    }
    
    static func createTimetable(title: String, courseBook: STCourseBook, done: ([STTimetable])->(), failure: ()->()) {
        Alamofire.request(STTimetableRouter.CreateTimetable(title: title, courseBook: courseBook)).responseWithDone({ statusCode, json in
            let timetables = json.arrayValue
            let timetableList = timetables.map { json in
                return STTimetable(json: json)
            }
            done(timetableList)
            }, failure: { _ in
                failure()
        })
    }
    
    static func updateTimetable(id: String, title: String, done: (()->())?) {
        let request = Alamofire.request(STTimetableRouter.UpdateTimetable(id: id, title: title))
        request.responseWithDone({ _ in
                done?()
            }, failure: nil
        )
    }
    
    static func deleteTimetable(id: String, done: ()->(), failure: ()->()) {
        Alamofire.request(STTimetableRouter.DeleteTimetable(id: id)).responseWithDone({ statusCode, json in
            done()
        }, failure: { _ in
            failure()
        })
    }
    
    static func getTimetable(id: String, done: (STTimetable?)->(), failure: ()->()) {
        Alamofire.request(STTimetableRouter.GetTimetable(id: id)).responseWithDone({ statusCode, json in
            if statusCode == 404 {
                done(nil)
                return
            }
            let timetable = STTimetable(json: json)
            done(timetable)
        }, failure: { _ in
            failure()
        })
    }
    
    static func getRecentTimetable(done: (STTimetable?)->(), failure: ()->()) {
        Alamofire.request(STTimetableRouter.GetRecentTimetable())
            .responseWithDone({ statusCode, json in
                if statusCode == 404 {
                    done(nil)
                } else {
                    done(STTimetable(json: json))
                }
            }, failure: { _ in
                failure()
            })
    }
    
    //MARK: LectureRouter
    
    static func addCustomLecture(timetable: STTimetable, lecture: STLecture, done: (STTimetable)->(), failure: ()->()) {
        let request = Alamofire.request(STLectureRouter.AddCustomLecture(timetableId: timetable.id!, lecture: lecture))
        request.responseWithDone({ statusCode, json in
            done(STTimetable(json: json))
            }, failure: { _ in
            failure()
        })
    }
    
    static func addLecture(timetable: STTimetable, lectureId: String, done: (STTimetable)->(), failure: ()->()) {
        let request = Alamofire.request(STLectureRouter.AddLecture(timetableId: timetable.id!, lectureId: lectureId))
        request.responseWithDone({ statusCode, json in
            done(STTimetable(json: json))
            }, failure: { _ in
                failure()
        })
    }
    
    static func updateLecture(timetable: STTimetable, oldLecture: STLecture, newLecture: STLecture, done: (STTimetable)->(), failure: ()->()) {
        let request = Alamofire.request(STLectureRouter.UpdateLecture(timetableId: timetable.id!, oldLecture: oldLecture, newLecture : newLecture))
        request.responseWithDone({ statusCode, json in
            done(STTimetable(json: json))
            }, failure: { _ in
                failure()
            }, showNetworkAlert: true, alertTitle: "강좌 수정 실패"
        )
    }
    
    static func deleteLecture(timetable: STTimetable, lecture: STLecture, done: ()->(), failure: ()->()) {
        let request = Alamofire.request(STLectureRouter.DeleteLecture(timetableId: timetable.id!, lecture: lecture))
        request.responseWithDone({ statusCode, json in
            if json["success"].boolValue {
                done()
            } else {
                failure()
            }
            }, failure: { _ in
                failure()
        })
    }
    
    static func resetLecture(timetable: STTimetable, lecture: STLecture, done: (STTimetable)->(), failure: (()->())?) {
        let request = Alamofire.request(STLectureRouter.ResetLecture(timetableId: timetable.id!, lectureId: lecture.id!))
        request.responseWithDone({ statusCode, json in
                done(STTimetable(json: json))
            }, failure: { _ in
                failure?()
        })
    }
    
    //MARK: TagRouter
    
    static func getTagListForQuarter(quarter: STQuarter, done: ([STTag])->(), failure: ()->()) {
        let request = Alamofire.request(STTagRouter.Get(quarter: quarter))
        request.responseWithDone ({ statusCode, json in
            var tags = json["classification"].arrayValue.map({ body in
                return STTag(type: .Classification, text: body.stringValue)
            })
            tags = tags + json["department"].arrayValue.map({ body in
                return STTag(type: .Department, text: body.stringValue)
            })
            tags = tags + json["academic_year"].arrayValue.map({ body in
                return STTag(type: .AcademicYear, text: body.stringValue)
            })
            tags = tags + json["credit"].arrayValue.map({ body in
                return STTag(type: .Credit, text: body.stringValue)
            })
            tags = tags + json["instructor"].arrayValue.map({ body in
                return STTag(type: .Instructor, text: body.stringValue)
            })
            tags = tags + json["category"].arrayValue.map({ body in
                return STTag(type: .Category, text: body.stringValue)
            })
            done(tags)
        }, failure: { _ in
            failure()
        })
    }
    
    static func getTagUpdateTimeForQuarter(quarter: STQuarter, done: (String)->(), failure: ()->()) {
        let request = Alamofire.request(STTagRouter.UpdateTime(quarter: quarter))
        request.responseWithDone({ statusCode, json in
            let updatedTime = json.stringValue
            done(updatedTime)
        }, failure: { _ in
            failure()
        })
    }
    
    //MARK: NotificationRouter
    
    static func getNotificationList(limit: Int, offset: Int, explicit: Bool, done: ([STNotification])->(), failure: ()->()) {
        let request = Alamofire.request(STNotificationRouter.NotificationList(limit: limit, offset: offset, explicit: explicit))
        request.responseWithDone({ statusCode, json in
            let notiList = json.arrayValue.map { it in
                return STNotiUtil.parse(it)
            }
            done(notiList)
        }, failure: { _ in
            failure()
        })
    }
    
    static func getNotificationCount(done: (Int)->(), failure: ()->()) {
        let request = Alamofire.request(STNotificationRouter.NotificationCount)
        request.responseWithDone({ statusCode, json in
            done(json["count"].intValue)
        }, failure: { _ in
            failure()
        })
    }
    
    //MARK: CourseBookRouter
    
    static func getCourseBookList(done: ([STCourseBook])->(), failure: ()->()) {
        let request = Alamofire.request(STCourseBookRouter.Get)
        request.responseWithDone({ statusCode, json in
            let list = json.arrayValue.map({ json in
                return STCourseBook(json: json)
            })
            done(list)
            }, failure: { _ in
                failure()
        })
    }
    
    static func getSyllabus(quarter: STQuarter, lecture: STLecture, done:(String)->(), failure: (()->())?) {
        let request = Alamofire.request(STCourseBookRouter.Syllabus(quarter: quarter, lecture: lecture))
        request.responseWithDone({ statusCode, json in
            let url = json["url"].stringValue
            done(url)
            }, failure: { _ in
                failure?()
        }, showNetworkAlert: false, showAlert: false)

    }
    
    //MARK: UserRouter
    
    static func detachFB(done:()->(), failure: ()->()) {
        let request = Alamofire.request(STUserRouter.DetachFB)
        request.responseWithDone({ _, json in
            STDefaults[.token] = json["token"].stringValue
            done()
            }, failure: { _ in
                failure()
        })
    }
    
    static func attachFB(fb_id fb_id: String, fb_token: String, done:()->(), failure: ()->()) {
        let request = Alamofire.request(STUserRouter.AddFB(id: fb_id, token: fb_token))
        request.responseWithDone({ _, json in
            if let token = json["token"].string {
                STDefaults[.token] = token
            }
            done()
            }, failure: { _ in
                failure()
        })
    }
    
    static func unregister(failure: ()->()) {
        let request = Alamofire.request(STUserRouter.DeleteUser)
        request.responseWithDone({ _, json in
            STUser.loadLoginPage()
            }, failure: { _ in
                failure()
        })
    }
    
    static func editUser(email: String, done: ()->(), failure: ()->()) {
        let request = Alamofire.request(STUserRouter.EditUser(email: email))
        request.responseWithDone({ _, _ in
            done()
            }, failure: { _ in
                failure()
        })
    }
    
    static func changePassword(curPassword: String, newPassword: String, done: () -> (), failure: (String?)->()) {
        let request = Alamofire.request(STUserRouter.ChangePassword(oldPassword: curPassword, newPassword: newPassword))
        request.responseWithDone({ statusCode, json in
            if let token = json["token"].string {
                STDefaults[.token] = token
            }
            done()
            }, failure: { _ in
                failure(nil)
        })
    }
    
    static func addDevice(deviceId : String) {
        let request = Alamofire.request(STUserRouter.AddDevice(id: deviceId))
        request.responseWithDone({ statusCode, json in
            STDefaults[.isFCMRegistered] = true
            }, failure: nil
            , showNetworkAlert: false
        )
    }
    
    static func deleteDevice(deviceId : String) {
        let request = Alamofire.request(STUserRouter.DeleteDevice(id: deviceId))
        request.responseWithDone({ statusCode, json in
            }, failure: { _ in
                //TODO: Error Handling with deleteDevice
            }, showNetworkAlert: false
        )
    }
    
    static func addLocalID(id: String, password: String, done: ()->()) {
        let request = Alamofire.request(STUserRouter.AddLocalId(id: id, password: password))
        request.responseWithDone({statusCode, json in
            if let token = json["token"].string {
                STDefaults[.token] = token
            }
            STUser.getUser()
            done()
        }, failure: nil)
    }
    
    static func showNetworkError() {
        let alert = UIAlertController(title: "Network Error", message: "네트워크 환경이 원활하지 않습니다.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: nil))
        UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: STEtcRouter
    
    static func sendFeedback(email: String?, message: String, done: (()->())?) {
        let request = Alamofire.request(STEtcRouter.Feedback(email: email, message: message))
        request.responseWithDone({ _ in
                done?()
            }, failure: nil)
    }
    
    //MARK: AppVersion
    
    static func checkLatestAppVersion(done:(String)->()) -> Void {
        
        let requestURL = "http://itunes.apple.com/kr/lookup?bundleId=" + NSBundle.mainBundle().bundleIdentifier!
        
        Alamofire.request(.GET, requestURL).responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                let version = json["results"].array?.first?["version"].string
                if version == nil {
                    fallthrough
                }
                done(version!)
            case .Failure:
                break
            }
        }
    }
    
}
