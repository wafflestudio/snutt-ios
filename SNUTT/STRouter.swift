//
//  STRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 7. 22..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

protocol STRouter : URLRequestConvertible {
    
    static var baseURLString : String { get }
    static var shouldAddToken : Bool { get }
    var method: Alamofire.Method { get }
    var path: String { get }
    var parameters: [String: AnyObject]? { get }
    
}

extension STRouter {
    
    var defaultURLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Self.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path)!)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        let apikey = STDefaults[.apiKey]
        mutableURLRequest.setValue(apikey, forHTTPHeaderField: "x-access-apikey")
        return mutableURLRequest
    }
    
    var tokenedURLRequest: NSMutableURLRequest {
        let mutableURLRequest = self.defaultURLRequest
        if let token = STDefaults[.token] {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "x-access-token")
        }
        return mutableURLRequest
    }
    
    var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = Self.shouldAddToken ? self.tokenedURLRequest : self.defaultURLRequest
        #if DEBUG
        print(Self.baseURLString + path)
        #endif
        switch self.method {
        case .GET:
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: self.parameters).0
        default:
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: self.parameters).0
        }
    }
}
