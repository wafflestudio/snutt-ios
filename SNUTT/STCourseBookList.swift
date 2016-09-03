//
//  STCourseBookList.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STCourseBookList {
    // MARK: Singleton
    
    private static var sharedManager : STCourseBookList? = nil
    static var sharedInstance : STCourseBookList {
        get {
            if sharedManager == nil {
                sharedManager = STCourseBookList()
            }
            return sharedManager!
        }
    }
    private init() {
        self.loadCourseBooks()
        self.getCourseBooks()
    }
    
    var courseBookList : [STCourseBook] = []
    
    func loadCourseBooks () {
        
        guard let courseBookList = NSKeyedUnarchiver.unarchiveObjectWithFile(getDocumentsDirectory().stringByAppendingPathComponent("courseBookList.archive")) as? [NSDictionary] else {
            self.courseBookList = []
            return
        }
        self.courseBookList = courseBookList.map({ dict in
            return STCourseBook(dictionary: dict)!
        })
    }
    
    func saveCourseBooks () {
        NSKeyedArchiver.archiveRootObject(courseBookList.map({ book in
            return book.dictionaryValue()
        }), toFile: getDocumentsDirectory().stringByAppendingPathComponent("courseBookList.archive"))
    }
    
    func getCourseBooks () {
        STNetworking.getCourseBookList({ list in
            self.courseBookList = list
            STEventCenter.sharedInstance.postNotification(event: .CourseBookUpdated, object: nil)
            self.saveCourseBooks()
            }, failure: { _ in
                return
        })
    }
    
}