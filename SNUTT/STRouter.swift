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
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    
}

extension STRouter {
    
    var defaultURLRequest: NSMutableURLRequest {
        let URL = Foundation.URL(string: Self.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue
        
        let apikey = STConfig.sharedInstance.apiKey
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
    
    func asURLRequest() throws -> URLRequest {
        let mutableURLRequest = Self.shouldAddToken ? self.tokenedURLRequest : self.defaultURLRequest
        #if DEBUG
        print(Self.baseURLString + path)
        #endif
        switch self.method {
        case .get:
            return try Alamofire.URLEncoding.default.encode(mutableURLRequest as URLRequest, with: self.parameters)
        default:
            return try Alamofire.JSONEncoding.default.encode(mutableURLRequest as URLRequest, with: self.parameters)
        }
    }
}
