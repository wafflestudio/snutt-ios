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
    }
    
    var courseBookList : [STCourseBook]?
    
    func loadCourseBooks () {
        //TODO : Add networking
        courseBookList = [
            STCourseBook(year: 2016, semester: .First),
            STCourseBook(year: 2015, semester: .Winter),
            STCourseBook(year: 2015, semester: .Second),
            STCourseBook(year: 2015, semester: .Summer),
            STCourseBook(year: 2015, semester: .First),
            STCourseBook(year: 2014, semester: .Winter),
            STCourseBook(year: 2014, semester: .Second)
        ]
    }
    
}