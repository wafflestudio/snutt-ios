//
//  STAPI.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 7..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

class STAPI {
    
    private static var manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: "http://snutt.kr/api/"))
    
    static func GET(url: String, parameters: AnyObject?, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)? ) {
        STAPI.manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func POST(url: String, parameters: AnyObject?, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)? ) {
        STAPI.manager.POST(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func getCourseBookInfo(success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)?) {
        STAPI.GET("init_client", parameters: nil, success: success, failure: failure)
    }
}