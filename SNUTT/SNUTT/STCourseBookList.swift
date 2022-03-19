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
    
    fileprivate static var sharedManager : STCourseBookList? = nil
    static var sharedInstance : STCourseBookList {
        get {
            if sharedManager == nil {
                sharedManager = STCourseBookList()
            }
            return sharedManager!
        }
    }
    fileprivate init() {
        self.loadCourseBooks()
        self.getCourseBooks()
    }
    
    var courseBookList : [STCourseBook] = []
    
    func loadCourseBooks () {
        
        guard let courseBookList = NSKeyedUnarchiver.unarchiveObject(withFile: getDocumentsDirectory().appendingPathComponent("courseBookList.archive")) as? [NSDictionary] else {
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
        }), toFile: getDocumentsDirectory().appendingPathComponent("courseBookList.archive"))
    }
    
    func getCourseBooks () {
        STNetworking.getCourseBookList({ list in
            self.courseBookList = list
            STEventCenter.sharedInstance.postNotification(event: .CourseBookUpdated, object: nil)
            self.saveCourseBooks()
            }, failure: { 
                return
        })
    }
    
}
