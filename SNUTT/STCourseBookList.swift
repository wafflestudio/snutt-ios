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
            STCourseBook(year: 2016, semester: 0),
            STCourseBook(year: 2015, semester: 3),
            STCourseBook(year: 2015, semester: 2),
            STCourseBook(year: 2015, semester: 1),
            STCourseBook(year: 2015, semester: 0),
            STCourseBook(year: 2014, semester: 3),
            STCourseBook(year: 2014, semester: 2)
        ]
    }
    
}