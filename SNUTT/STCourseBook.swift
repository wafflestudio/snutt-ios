//
//  STCourseBook.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STCourseBook: NSObject, NSCoding{
    
    var lectureList : [STLecture] = []
    var singleClassList : [STSingleClass] = []
    var year : Int = 0
    var semester : String = ""
    
    init(year aYear: Int, semester aSemester: String) {
        self.year = aYear
        self.semester = aSemester
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
        semester = aDecoder.decodeObjectForKey("semester") as! String
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(lectureList, forKey: "lectureList")
        aCoder.encodeObject(year, forKey: "year")
        aCoder.encodeObject(semester, forKey: "semester")
        
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
        STCourseBooksManager.sharedInstance.saveData()
        //collectionView?.reloadData()
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
        STCourseBooksManager.sharedInstance.saveData()
        //collectionView?.reloadData()
    }
}
