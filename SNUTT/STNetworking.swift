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
        let request = Alamofire.request(STAuthRouter.LocalLogin(id, password))
        request.responseWithDone({json in
            let token = json.stringValue
            done(token)
            }, failure: { _ in
            failure()
        })
    }
    
    //MARK: LectureRouter
    static func addLecture(timetable: STTimetable, lecture: STLecture, done: (String)->(), failure: ()->()) {
        let request = Alamofire.request(STLectureRouter.AddLecture(timetableId: timetable.id!, lecture: lecture))
        request.responseWithDone({ json in
            done(json.stringValue)
            }, failure: { _ in
            failure()
        })
    }
    
    static func updateLecture(timetable: STTimetable, lecture: STLecture, done: ()->(), failure: ()->()) {
        let request = Alamofire.request(STLectureRouter.UpdateLecture(timetableId: timetable.id!, lecture: lecture))
        request.responseWithDone({ json in
            if json["success"].boolValue {
                done()
            } else {
                failure()
            }
            }, failure: { _ in
                failure()
        })
    }
    
    static func deleteLecture(timetable: STTimetable, lecture: STLecture, done: ()->(), failure: ()->()) {
        let request = Alamofire.request(STLectureRouter.DeleteLecture(timetableId: timetable.id!, lecture: lecture))
        request.responseWithDone({ json in
            if json["success"].boolValue {
                done()
            } else {
                failure()
            }
            }, failure: { _ in
                failure()
        })
    }
    
    //MARK: TagRouter
    
    static func getTagListForQuarter(quarter: STQuarter, done: ([STTag])->(), failure: ()->()) {
        let request = Alamofire.request(STTagRouter.Get(quarter: quarter))
        request.responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                var tags = json["classification"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["department"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["academic_year"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["credit"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["instructor"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                done(tags)
            case .Failure:
                failure()
            }
        }
    }
    
    static func getTagUpdateTimeForQuarter(quarter: STQuarter, done: (String)->(), failure: ()->()) {
        let request = Alamofire.request(STTagRouter.UpdateTime(quarter: quarter))
        request.responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                let updatedTime = json.stringValue
                done(updatedTime)
            case .Failure:
                failure()
            }
        }
    }
    
}