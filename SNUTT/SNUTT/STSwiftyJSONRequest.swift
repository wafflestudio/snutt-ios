//
//  STSwiftyJSONRequest.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 17..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

// code referenced from https://github.com/SwiftyJSON/Alamofire-SwiftyJSON

import Foundation
import Alamofire
import SwiftyJSON

extension Request {
    /// Returns a SwiftyJSON object contained in a result type constructed from the response data using `JSONSerialization`
    /// with the specified reading options.
    ///
    /// - parameter options:  The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - parameter response: The response from the server.
    /// - parameter data:     The data returned from the server.
    /// - parameter error:    The error already encountered if it exists.
    ///
    /// - returns: The result data type.
    public static func serializeResponseSwiftyJSON(
        options: JSONSerialization.ReadingOptions,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
        -> Result<JSON>
    {
        guard error == nil else { return .failure(error!) }

        if let response = response, emptyDataStatusCodes.contains(response.statusCode) { return .success(JSON.null) }

        guard let validData = data, validData.count > 0 else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
        }

        do {
            let json = try JSONSerialization.jsonObject(with: validData, options: options)
            return .success(JSON(json))
        } catch {
            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
        }
    }
}

extension DataRequest {
    /// Creates a response serializer that returns a SwiftyJSON object result type constructed from the response data using
    /// `JSONSerialization` with the specified reading options.
    ///
    /// - parameter options: The JSON serialization reading options. Defaults to `.allowFragments`.
    ///
    /// - returns: A JSON object response serializer.
    public static func swiftyJSONResponseSerializer(
        options: JSONSerialization.ReadingOptions = .allowFragments)
        -> DataResponseSerializer<JSON>
    {
        return DataResponseSerializer { _, response, data, error in
            return Request.serializeResponseSwiftyJSON(options: options, response: response, data: data, error: error)
        }
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter options: The JSON serialization reading options. Defaults to `.allowFragments`.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseSwiftyJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (DataResponse<JSON>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.swiftyJSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }

    public func responseWithDone(_ done: ((Int, JSON) -> ())?, failure: ((STErrorCode) -> ())?, showNetworkAlert: Bool = true, showAlert: Bool = true, alertTitle: String? = nil ) {
        self.responseSwiftyJSON { response in
            switch response.result {
            case .success(let json):
                #if DEBUG
                    print(json)
                #endif
                if let statusCode = response.response?.statusCode {
                    if statusCode != 200 {
                        guard let errCodeRaw = json["errcode"].int else {
                            done?(response.response?.statusCode ?? 200 ,json)
                            return
                        }
                        guard let errCode = STErrorCode(rawValue: errCodeRaw) else {
                            failure?(STErrorCode.SERVER_FAULT)
                            return
                        }
                        switch (errCode) {
                        case STErrorCode.NO_USER_TOKEN, STErrorCode.WRONG_USER_TOKEN:
                            STUser.logOut()
                        default:
                            if showAlert {
                                if let alertTitle = alertTitle {
                                    STAlertView.showAlert(title: alertTitle, message: errCode.errorMessage)
                                } else {
                                    STAlertView.showAlert(title: errCode.errorTitle, message: errCode.errorMessage)
                                }
                            }
                        }
                        failure?(errCode)
                        return
                    }
                }
                done?(response.response?.statusCode ?? 200 ,json)
            case .failure(let error):
                #if DEBUG
                    print("Error on Networking")
                #endif
                if case AFError.responseSerializationFailed = error {
                    let errorCode = STErrorCode.SERVER_FAULT
                    if showNetworkAlert {
                        STAlertView.showAlert(title: errorCode.errorTitle, message: errorCode.errorMessage)
                    }
                    failure?(errorCode)
                } else {
                    if showNetworkAlert {
                        
                        STNetworking.showNetworkError()
                    }
                    failure?(STErrorCode.NO_NETWORK)
                }
            }
        }
    }
}

private let emptyDataStatusCodes: Set<Int> = [204, 205]

/*

extension JSON {
    public var date : NSDate? {
        let dateFor: NSDateFormatter = NSDateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:SSS"
        
        return dateFor.dateFromString(self.stringValue)
    }
}
*/
