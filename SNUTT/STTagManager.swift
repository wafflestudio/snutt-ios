//
//  STTagManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

class STTagManager {
    
    // MARK: Singleton
    
    private static var sharedManager : STTagManager? = nil
    static var sharedInstance : STTagManager{
        get {
            if sharedManager == nil {
                sharedManager = STTagManager()
            }
            return sharedManager!
        }
    }
    
    private init() {
        self.loadData()
        STEventCenter.sharedInstance.addObserver(self, selector: "loadData", event: STEvent.CurrentTimetableSwitched, object: nil)
    }
    
    var tagList : STTagList!
    
    dynamic func loadData() {
        //TODO : load from local data else create fake taglist
        guard let quarter = STTimetableManager.sharedInstance.currentTimetable?.quarter else {
            return
        }
        let tagList = NSKeyedUnarchiver.unarchiveObjectWithFile(getDocumentsDirectory().stringByAppendingPathComponent("tagList\(quarter.shortString()).archive")) as? STTagList
        if tagList != nil {
            self.tagList = tagList
        } else {
            self.tagList = STTagList(quarter: quarter, tagList: [], updatedTime: "")
        }
        self.updateTagList()
    }
    
    func saveData(quarter: STQuarter) {
        //TODO : save to local data
        NSKeyedArchiver.archiveRootObject(self.tagList, toFile: getDocumentsDirectory().stringByAppendingPathComponent("tagList\(quarter.shortString()).archive"))
        
        
    }
    
    
    
    
    func getTagListWithQuarter(quarter: STQuarter, updatedTime : String) {
        let request = Alamofire.request(STTagRouter.Get(quarter: quarter))
        request.responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                var tags = json["classification"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["category"].arrayValue.map({ body in
                    return STTag(type: .Category, text: body.stringValue)
                })
                tags = tags + json["department"].arrayValue.map({ body in
                    return STTag(type: .Department, text: body.stringValue)
                })
                tags = tags + json["academic_year"].arrayValue.map({ body in
                    return STTag(type: .AcademicYear, text: body.stringValue)
                })
                tags = tags + json["credit"].arrayValue.map({ body in
                    return STTag(type: .Credit, text: body.stringValue)
                })
                tags = tags + json["instructor"].arrayValue.map({ body in
                    return STTag(type: .Instructor, text: body.stringValue)
                })
                if self.tagList.quarter == quarter {
                    self.tagList = STTagList(quarter: quarter, tagList: tags, updatedTime: updatedTime)
                    self.saveData(quarter)
                }
            case .Failure(let error):
                //TODO : Alertview for failure
                print(error)
            }
        }
    }


    
    func updateTagList() {
        let request = Alamofire.request(STTagRouter.UpdateTime(quarter: tagList.quarter))
        request.responseString { response in
            switch response.result {
            case .Success(let updatedTime):
                if self.tagList.updatedTime != updatedTime {
                    self.getTagListWithQuarter(self.tagList.quarter, updatedTime: updatedTime)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

}