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
    
    public func responseWithDone(done: ((JSON) -> ())?, failure: ((NSError) -> ())? ) {
        self.responseSwiftyJSON { response in
            switch response.result {
            case .Success(let json):
                done?(json)
            case .Failure(let error):
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