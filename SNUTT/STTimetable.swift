//
//  STTimetable.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STTimetable : NSObject, NSCoding {
    
    var lectureList : [STLecture] = []
    var singleClassList : [STSingleClass] = []
    var year : Int
    var semester : Int
    var title : String
    weak var timeTableController : STTimetableCollectionViewController? = nil
    
    static let semesterToString = ["1", "S", "2", "W"]
    static let semesterToLongString = ["1", "여름", "2", "겨울"]
    
    func quarterToString() -> String {
        return "\(year)" + "-" + STTimetable.semesterToString[semester]
    }
    
    init(year aYear: Int, semester aSemester: Int, title aTitle: String) {
        self.year = aYear
        self.semester = aSemester
        self.title = aTitle
        super.init()
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
    
    enum AddLectureState {
        case Success, ErrorTime, ErrorSameLecture
    }
    func addLecture(lecture : STLecture) -> AddLectureState {
        for it in lectureList {
            if it.isEquals(lecture){
                return AddLectureState.ErrorSameLecture
            }
        }
        for it in singleClassList {
            for jt in lecture.classList {
                if it.isOverlappingWith(jt) {
                    return AddLectureState.ErrorTime
                }
            }
        }
        lectureList.append(lecture)
        for it in lecture.classList {
            singleClassList.append(it)
        }
        timeTableController?.reloadTimetable();
        return AddLectureState.Success
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
        timeTableController?.reloadTimetable();
    }
}
