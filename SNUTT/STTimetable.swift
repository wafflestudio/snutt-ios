//
//  STTimetable.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

enum STAddLectureState {
    case Success, ErrorTime, ErrorSameLecture
}

class STTimetable : NSObject, NSCoding {
    
    private(set) var lectureList : [STLecture] = []
    private(set) var singleClassList : [STSingleClass] = []
    private(set) var year : Int
    private(set) var semester : Int
    private(set) var title : String
    private(set) var id : String?
    
    static let semesterToString = ["1", "S", "2", "W"]
    static let semesterToLongString = ["1", "여름", "2", "겨울"]
    
    func quarterToString() -> String {
        return "\(year)" + "-" + STTimetable.semesterToString[semester]
    }
    
    var isLoaded : Bool {
        get {
            return !(id==nil)
        }
    }
    
    init(year aYear: Int, semester aSemester: Int, title aTitle: String) {
        self.year = aYear
        self.semester = aSemester
        self.title = aTitle
        super.init()
    }
    
    init(json : JSON) {
        self.year = json["year"].intValue
        self.semester = json["semester"].intValue
        self.title = json["title"].stringValue
        self.id = json["_id"].string
        super.init()
        let lectures = json["lectures"].arrayValue
        lectures.forEach {data in
            self.addLecture(STLecture(json: data))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        lectureList = aDecoder.decodeObjectForKey("lectureList") as! [STLecture]
        singleClassList.removeAll(keepCapacity: true)
        for it in lectureList {
            for jt in it.classList {
                singleClassList.append(jt)
            }
        }
        year = aDecoder.decodeObjectForKey("year") as! Int
        semester = aDecoder.decodeObjectForKey("semester") as! Int
        title = aDecoder.decodeObjectForKey("title") as! String
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(lectureList, forKey: "lectureList")
        aCoder.encodeObject(year, forKey: "year")
        aCoder.encodeObject(semester, forKey: "semester")
        aCoder.encodeObject(title, forKey: "title")
    }
    
    func addLecture(lecture : STLecture) -> STAddLectureState {
        for it in lectureList {
            if it.isEquals(lecture){
                return STAddLectureState.ErrorSameLecture
            }
        }
        for it in singleClassList {
            for jt in lecture.classList {
                if it.isOverlappingWith(jt) {
                    return STAddLectureState.ErrorTime
                }
            }
        }
        lectureList.append(lecture)
        for it in lecture.classList {
            singleClassList.append(it)
        }
        return STAddLectureState.Success
    }
    func deleteLecture(lecture : STLecture) {
        for (var i=0; i<singleClassList.count; i++) {
            if singleClassList[i].lecture === lecture {
                singleClassList.removeAtIndex(i)
                i--
            }
        }
        for (var i=0; i<lectureList.count; i++) {
            if lectureList[i] === lecture {
                lectureList.removeAtIndex(i)
                break
            }
        }
    }
}
