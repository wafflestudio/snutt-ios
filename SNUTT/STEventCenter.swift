//
//  STEventCenter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 10..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STEvent : String {
    case CurrentTimetableSwitched = "CurrentTimetableSwitched"
    case CurrentTimetableChanged = "CurrentTimetableChanged"
    case CurrentTemporaryLectureChanged = "CurrentTemporaryLectureChanged"
    case SettingChanged = "SettingChanged"
    case CourseBookUpdated = "CourseBookUpdated"
    case TagListUpdated = "TagListUpdated"
    case UserUpdated = "UserUpdated"
    case ColorListUpdated = "ColorListUpdated"
}

class STEventCenter : NSNotificationCenter {
    
    // MARK: Singleton
    
    private static var sharedEventCenter : STEventCenter? = nil
    
    static var sharedInstance : STEventCenter {
        get {
            if sharedEventCenter == nil {
                sharedEventCenter = STEventCenter()
            }
            return sharedEventCenter!
        }
    }
    private override init() {
        super.init()
    }
    
    func addObserver(observer: AnyObject, selector aSelector: Selector, event aEvent : STEvent, object anObject: AnyObject?) {
        self.addObserver(observer, selector: aSelector, name: aEvent.rawValue, object: anObject)
    }
    
    func postNotification(event aEvent : STEvent, object anObject: AnyObject?) {
        self.postNotificationName(aEvent.rawValue, object: anObject)
    }
    
}
