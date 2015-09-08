//
//  STCourseBooksManager.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STCourseBooksManager : NSObject {
    
    // MARK: Singleton
    
    private static var sharedManager : STCourseBooksManager? = nil
    static var sharedInstance : STCourseBooksManager{
        get {
            if sharedManager == nil {
                sharedManager = STCourseBooksManager()
            }
            return sharedManager!
        }
    }
    private override init() {
        super.init()
        self.loadData()
        self.refreshDataIfAvailable()
    }
    
    var courseBookList : [STCourseBook] = []
    var currentCourseBook : STCourseBook? = nil
    var currentCourseBookIndex : Int = -1 {
        didSet {
            if courseBookList.count > currentCourseBookIndex && currentCourseBookIndex >= 0 {
                currentCourseBook = courseBookList[currentCourseBookIndex]
            }
        }
    }
    var timeTableController : STTimeTableCollectionViewController? = nil
    
    func reloadTimeTable() {
        timeTableController?.reloadTimeTable()
    }
    
    func loadData() {
        let ud = NSUserDefaults.standardUserDefaults()
        if let data = ud.objectForKey("courseBookList") as? NSData {
            let unarc = NSKeyedUnarchiver(forReadingWithData: data )
            courseBookList = unarc.decodeObjectForKey("root") as! [STCourseBook]
        }
        if let data = ud.objectForKey("currentCourseBookIndex") as? NSData {
            let unarc = NSKeyedUnarchiver(forReadingWithData: data )
            currentCourseBookIndex = unarc.decodeObjectForKey("root") as! Int
        } else {
            currentCourseBookIndex = -1
        }
    }
    
    func refreshDataIfAvailable() {
        STAPI.getCourseBookInfo({(operation : AFHTTPRequestOperation, response : AnyObject) -> Void in
            
            let infoDic = response as! NSDictionary
            let courseBookInfoList = infoDic["coursebook_info"] as! [NSDictionary]
            let lastCourseBookInfo = infoDic["last_coursebook_info"] as! NSDictionary
            var insertCourseBookList : [STCourseBook] = []
            for i in 0..<courseBookInfoList.count {
                let info = courseBookInfoList[i]
                var year = (info["year"] as! String).toInt()!
                var semester = info["semester"] as! String
                if self.courseBookList.last != nil && self.courseBookList.last!.year == year && self.courseBookList.last!.semester == semester{
                    break
                }
                insertCourseBookList.append(STCourseBook(year: year, semester: semester))
            }
            
            //put course book in reverse order
            for var i=insertCourseBookList.count-1; i>=0; i-- {
                self.courseBookList.append(insertCourseBookList[i])
            }
            
            if self.currentCourseBookIndex == -1 {
                self.currentCourseBookIndex = self.courseBookList.count - 1
                self.reloadTimeTable()
            }
            self.saveData()
            
        }, failure: nil)
    }
    
    func saveData() {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(NSKeyedArchiver.archivedDataWithRootObject(courseBookList), forKey: "courseBookList")
        ud.setObject(NSKeyedArchiver.archivedDataWithRootObject(currentCourseBookIndex), forKey: "currentCourseBookIndex")
    }
    
}