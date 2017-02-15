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
        NSKeyedArchiver.archiveRootObject(self.tagList, toFile: getDocumentsDirectory().stringByAppendingPathComponent("tagList\(quarter.shortString()).archive"))
    }
    
    
    
    
    func getTagListWithQuarter(quarter: STQuarter, updatedTime : String) {
        STNetworking.getTagListForQuarter(quarter, done: { list in
            if self.tagList.quarter == quarter {
                self.tagList = STTagList(quarter: quarter, tagList: list, updatedTime: updatedTime)
                self.saveData(quarter)
            }
        }, failure: { _ in
            self.tagList = STTagList(quarter: quarter, tagList: [], updatedTime: updatedTime)
        })
    }


    
    func updateTagList() {
        let request = Alamofire.request(STTagRouter.UpdateTime(quarter: tagList.quarter))
        request.responseString { response in
            switch response.result {
            case .Success(let updatedTime):
                if self.tagList.updatedTime != updatedTime {
                    self.getTagListWithQuarter(self.tagList.quarter, updatedTime: updatedTime)
                }
            case .Failure:
                break
            }
        }
    }

}
