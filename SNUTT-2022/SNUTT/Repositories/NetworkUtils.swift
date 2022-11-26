//
//  NetworkUtils.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/08.
//

import Alamofire
import Foundation
import UIKit
import FirebaseCrashlytics

final class Interceptor: RequestInterceptor {
    private let userState: UserState

    init(userState: UserState) {
        self.userState = userState
    }

    func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        urlRequest.setValue(userState.accessToken, forHTTPHeaderField: "x-access-token")

        AppMetadata.allCases
            .forEach { header in
                urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
            }

        completion(.success(urlRequest))
    }
}

enum AppMetadata: CaseIterable {
    case appVersion, appType, osType, osVersion, apiKey, buildNumber

    var value: String? {
        switch self {
        case .appVersion:
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        case .appType:
            #if DEBUG
                return "debug"
            #else
                return "release"
            #endif
        case .osType:
            return "ios"
        case .osVersion:
            return UIDevice.current.systemVersion
        case .apiKey:
            return NetworkConfiguration.apiKey
        case .buildNumber:
            return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        }
    }

    var key: String {
        switch self {
        case .appVersion:
            return "x-app-version"
        case .appType:
            return "x-app-type"
        case .osType:
            return "x-os-type"
        case .osVersion:
            return "x-os-version"
        case .apiKey:
            return "x-access-apikey"
        case .buildNumber:
            return "x-build-number"
        }
    }
}

final class Logger: EventMonitor {
    let queue = DispatchQueue(label: "NetworkingLog")

    // Event called when any type of Request is resumed.
    func requestDidResume(_ request: Request) {
        #if DEBUG
            debugPrint("Resuming: \(request)")
        #endif
    }

    // Event called whenever a DataRequest has parsed a response.
    func request<Value>(_: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
            if response.error == nil {
                debugPrint("Finished: \(response)")
            } else {
                debugPrint("Error: \(response)")
            }
        #endif
    }
}

extension DataTask {
    /// Extract DTO from `DataTask`, or throw error parsed from the response body.
    func handlingError() async throws -> Value {
        if let dto = try? await value {
            return dto
        }
        
        var userInfo: [String : Any] = [:]
        
        if let requestHeader = (await response.request?.headers.description) {
            userInfo["RequestHeader"] = requestHeader
        }
        
        if let requestBody = (await response.request?.httpBody),
           let requestBodyDecoded = String(data: requestBody, encoding: .utf8) {
            #if DEBUG
            debugPrint("Error Request Body: \(requestBodyDecoded)")
            #endif
            userInfo["RequestBody"] = requestBodyDecoded
        }
        
        if let responseBody = (await response.data),
           let responseBodyDecoded = String(data: responseBody, encoding: .utf8) {
            #if DEBUG
            debugPrint("Error Raw Response: \(responseBodyDecoded)")
            #endif
            userInfo["ResponseBody"] = responseBodyDecoded
        }
        
        if let data = await response.data,
           let errDto = try? JSONDecoder().decode(ErrorDto.self, from: data)
        {
            let errCode = ErrorCode(rawValue: errDto.errcode) ?? .SERVER_FAULT
            userInfo["ErrorMessage"] = errCode.errorMessage
            
            if errCode == .SERVER_FAULT {
                Crashlytics.crashlytics().record(error: NSError(domain: errCode.errorTitle, code: errCode.rawValue, userInfo: userInfo))
            }
            
            if let serverMessage = errDto.ext?.first?.1 {
                throw STError(errCode, content: serverMessage)
            } else {
                throw STError(errCode)
            }
        }
        
        Crashlytics.crashlytics().record(error: NSError(domain: "UNKNOWN_ERROR", code: -1, userInfo: userInfo))
        throw STError(.SERVER_FAULT)
    }
}
