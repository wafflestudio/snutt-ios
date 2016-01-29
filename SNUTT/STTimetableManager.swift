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
    func loadData() {
        currentTimetable = STTimetable(year: 2016, semester: 1, title: "TEST")
    }
    
    func saveData() {
        
    }
    
    func addLecture(lecture : STLecture, object : AnyObject? ) -> STAddLectureState {
        lecture.colorIndex = 1
        let ret = currentTimetable?.addLecture(lecture)
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        return ret!
    }
    func deleteLecture(lecture : STLecture, object : AnyObject? ) {
        currentTimetable?.deleteLecture(lecture)
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
    }
    func setTemporaryLecture(lecture :STLecture?, object : AnyObject? ) {
        currentTimetable?.temporaryLecture = lecture
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
    }
}