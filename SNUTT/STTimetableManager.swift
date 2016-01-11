//
//  STTimetableManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STTimetableManager : NSObject {
    
    // MARK: Singleton
    
    private static var sharedManager : STTimetableManager? = nil
    static var sharedInstance : STTimetableManager{
        get {
            if sharedManager == nil {
                sharedManager = STTimetableManager()
            }
            return sharedManager!
        }
    }
    private override init() {
        super.init()
        self.loadData()
    }
    
    var currentTimetable : STTimetable? {
        didSet {
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableSwitched, object: self)
        }
    }
    var timetableList : [STTimetable] = [STTimetable(year: 2016, semester: 0,title: "time1"),
        STTimetable(year: 2015, semester: 1,title: "time2"),
        STTimetable(year: 2015, semester: 3,title: "time3")]
    var indexList : [Int] = []
    func loadData() {
        currentTimetable = STTimetable(year: 2016, semester: 0, title: "TEST")
    }
    
    func saveData() {
        
    }
    
    func addLecture(lecture : STLecture, object : AnyObject? ) -> STAddLectureState {
        let ret = currentTimetable?.addLecture(lecture)
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        return ret!
    }
    func deleteLecture(lecture : STLecture, object : AnyObject? ) {
        currentTimetable?.deleteLecture(lecture)
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
    }
    
    func reloadTimetableList() {
        timetableList.sortInPlace({a, b in
            if a.year == b.year {
                return a.semester > b.semester
            }
            return a.year > b.year
        })
        indexList = []
        for i in 0..<timetableList.count {
            if(i == 0 || timetableList[i].title != timetableList[i-1].title) {
                indexList.append(i)
            }
        }
        indexList.append(timetableList.count)
    }

    
}