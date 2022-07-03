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
    private func setVersionHeaders(in request: NSMutableURLRequest) {
        request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "x-os-version")
        request.setValue("ios", forHTTPHeaderField: "x-os-type")
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue(appVersion, forHTTPHeaderField: "x-app-version")
        }
        #if DEBUG
            request.setValue("debug", forHTTPHeaderField: "x-app-type")
        #else
            request.setValue("release", forHTTPHeaderField: "x-app-type")
        #endif
    }

    var defaultURLRequest: NSMutableURLRequest {
        let URL = Foundation.URL(string: Self.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue

        let apikey = STDefaults[.apiKey]
        mutableURLRequest.setValue(apikey, forHTTPHeaderField: "x-access-apikey")
        setVersionHeaders(in: mutableURLRequest)
        return mutableURLRequest
    }

    var tokenedURLRequest: NSMutableURLRequest {
        let mutableURLRequest = defaultURLRequest
        if let token = STDefaults[.token] {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "x-access-token")
        }
        setVersionHeaders(in: mutableURLRequest)
        return mutableURLRequest
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
