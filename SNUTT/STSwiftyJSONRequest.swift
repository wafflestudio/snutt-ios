//
//  STSwiftyJSONRequest.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 17..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Request {
    
    public static func SwiftyJSONResponseSerializer(
        options options: NSJSONReadingOptions = .AllowFragments)
        -> ResponseSerializer<JSON, NSError>
    {
        return ResponseSerializer { _, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            if let response = response where response.statusCode == 204 { return Alamofire.Result.Success(JSON(NSNull)) }
            
            guard let validData = data where validData.length > 0 else {
                let failureReason = "JSON could not be serialized. Input data was nil or zero length."
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(validData, options: options)
                let swiftyJson = JSON(json)
                return Alamofire.Result.Success(swiftyJson)
            } catch {
                return .Failure(error as NSError)
            }
        }
    }
    
    public func responseSwiftyJSON(
        options options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: Response<JSON, NSError> -> Void)
        -> Self
    {
        return response(
            responseSerializer: Request.SwiftyJSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
    
    public func responseWithDone(done: ((Int, JSON) -> ())?, failure: ((NSError) -> ())?, networkAlert: Bool = true ) {
        self.responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                if let statusCode = response.response?.statusCode {
                    // FIXME: statusCodes
                    
                    if 400 <= statusCode && statusCode <= 403 {
                        let errCode = json["errcode"].intValue
                        if errCode == 1 {
                            // Token is wrong. => login page
                            STDefaults[.token] = nil
                            UIApplication.sharedApplication().delegate?.window??.rootViewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
                            return
                        } else if errCode == 0 {
                            // apiKey is wrong
                            // TODO: What if api key is wrong even though it should not happen.
                            // TODO: call failure
                            return
                        } else {
                            // something is wrong to the server
                            // TODO: alertview for server error
                            // TODO: call failure
                            return
                        }

                    }
                }
                done?(response.response?.statusCode ?? 200 ,json)
            case .Failure(let error):
                if networkAlert {
                    STNetworking.showNetworkError()
                }
                failure?(error)
            }
        }
    }
}

/*

extension JSON {
    public var date : NSDate? {
        let dateFor: NSDateFormatter = NSDateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:SSS"
        
        return dateFor.dateFromString(self.stringValue)
    }
}
*/