//
//  STRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 7. 22..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation

protocol STRouter: URLRequestConvertible {
    static var baseURLString: String { get }
    static var shouldAddToken: Bool { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
}

extension STRouter {
    var defaultURLRequest: NSMutableURLRequest {
        let URL = Foundation.URL(string: Self.baseURLString)!
        var mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue

        let apikey = STDefaults[.apiKey]
        mutableURLRequest.setValue(apikey, forHTTPHeaderField: "x-access-apikey")
        addAppInfoHeaders(to: &mutableURLRequest)
        addOSInfoHeaders(to: &mutableURLRequest)
        return mutableURLRequest
    }

    var tokenedURLRequest: NSMutableURLRequest {
        let mutableURLRequest = defaultURLRequest
        if let token = STDefaults[.token] {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "x-access-token")
        }
        return mutableURLRequest
    }
    
    func addAppInfoHeaders(to request: inout NSMutableURLRequest) {
        let appType: String
        #if DEBUG
        appType = "debug"
        #else
        appType = "release"
        #endif
        request.setValue(appType, forHTTPHeaderField: "x-app-type")
        request.setValue(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, forHTTPHeaderField: "x-app-version")
    }
    
    func addOSInfoHeaders(to request: inout NSMutableURLRequest) {
        request.setValue("ios", forHTTPHeaderField: "x-os-type")
        request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "x-os-version")
    }

    func asURLRequest() throws -> URLRequest {
        let mutableURLRequest = Self.shouldAddToken ? tokenedURLRequest : defaultURLRequest
        #if DEBUG
            print(Self.baseURLString + path)
        #endif
        switch method {
        case .get:
            return try Alamofire.URLEncoding.default.encode(mutableURLRequest as URLRequest, with: parameters)
        default:
            return try Alamofire.JSONEncoding.default.encode(mutableURLRequest as URLRequest, with: parameters)
        }
    }
}
