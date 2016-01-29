//
//  STSearchRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STSearchRouter : URLRequestConvertible {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/search_query"
    
    case Search(query : String)
    
    var method: Alamofire.Method {
        switch self {
        case .Search:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .Search:
            return ""
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: STSearchRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = STConfig.sharedInstance.token {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        switch self {
        case .Search(let title):
            let year = STTimetableManager.sharedInstance.currentTimetable!.year
            let semester = STTimetableManager.sharedInstance.currentTimetable!.semester
            let parameters : [String : AnyObject] = ["title" : title, "year" : year, "semester" : semester]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        }
    }
    
}