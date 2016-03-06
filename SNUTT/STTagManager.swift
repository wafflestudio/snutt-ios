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
    
    func loadData() {
        //TODO : load from local data else create fake taglist
        tagList = STTagList(quarter: STTimetableManager.sharedInstance.currentTimetable!.quarter, tagList: [], updatedTime: "")
        self.updateTagList()
    }
    
    func saveData() {
        //TODO : save to local data
        
    }
    
    
    
    
    func getTagListWithQuarter(quarter: STQuarter, updatedTime : String) {
        let request = Alamofire.request(STTagRouter.Get(quarter: quarter))
        request.responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                var tags = json["classification"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["department"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["academic_year"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["credit"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                tags = tags + json["instructor"].arrayValue.map({ body in
                    return STTag(type: .Classification, text: body.stringValue)
                })
                
                self.tagList = STTagList(quarter: quarter, tagList: tags, updatedTime: updatedTime)
                self.saveData()
            case .Failure(let error):
                //TODO : Alertview for failure
                print(error)
            }
        }
    }


    
    func updateTagList() {
        let request = Alamofire.request(STTagRouter.UpdateTime(quarter: tagList.quarter))
        request.responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                let updatedTime = json.stringValue
                if self.tagList.updatedTime != updatedTime {
                    self.getTagListWithQuarter(self.tagList.quarter, updatedTime: updatedTime)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

}