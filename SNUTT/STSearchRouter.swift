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
    
    case Search(query : String, tagList: [STTag])
    
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
        case let .Search(query, tagList):
            let year = STTimetableManager.sharedInstance.currentTimetable!.quarter.year
            let semester = STTimetableManager.sharedInstance.currentTimetable!.quarter.semester
            var credit : [Int] = []
            var professor : [String] = []
            var department : [String] = []
            var academicYear : [String] = []
            var classification : [String] = []
            for tag in tagList {
                switch tag.type {
                case .Credit:
                    credit.append(Int(tag.text.stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))!)
                case .Department:
                    department.append(tag.text)
                case .Instructor:
                    professor.append(tag.text)
                case .AcademicYear:
                    academicYear.append(tag.text)
                case .Classification:
                    classification.append(tag.text)
                }
            }
            
            let parameters : [String : AnyObject] = [
                "title" : query,
                "year" : year,
                "semester" : semester.rawValue,
                "credit" : credit /*,
                "professor" : professor,
                "department" : department,
                "academic_year" : academicYear,
                "classification" : classification*/
            ]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        }
    }
    
}