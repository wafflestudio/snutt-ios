//
//  STEventCenter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 10..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STEvent: String {
    case CurrentTimetableSwitched
    case CurrentTimetableChanged
    case CurrentTemporaryLectureChanged
    case SettingChanged
    case CourseBookUpdated
    case TagListUpdated
    case UserUpdated
    case ColorListUpdated
}

class STEventCenter: NotificationCenter {
    // MARK: Singleton

    fileprivate static var sharedEventCenter: STEventCenter?

    static var sharedInstance: STEventCenter {
        if sharedEventCenter == nil {
            sharedEventCenter = STEventCenter()
        }
        return sharedEventCenter!
    }

    override fileprivate init() {
        super.init()
    }

    func addObserver(_ observer: AnyObject, selector aSelector: Selector, event aEvent: STEvent, object anObject: AnyObject?) {
        addObserver(observer, selector: aSelector, name: NSNotification.Name(rawValue: aEvent.rawValue), object: anObject)
    }

    func postNotification(event aEvent: STEvent, object anObject: AnyObject?) {
        post(name: Notification.Name(rawValue: aEvent.rawValue), object: anObject)
    }
}
