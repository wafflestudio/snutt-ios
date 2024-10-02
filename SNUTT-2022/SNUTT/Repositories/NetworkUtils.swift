//
//  NetworkUtils.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/08.
//

import Alamofire
import FirebaseCrashlytics
import Foundation
import UIKit

final class Interceptor: RequestInterceptor {
    private let userState: UserState

    init(userState: UserState) {
        self.userState = userState
    }

    func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        urlRequest.setValue(userState.accessToken, forHTTPHeaderField: "x-access-token")

        for header in AppMetadata.allCases {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }

        completion(.success(urlRequest))
    }
}

enum AppMetadata: CaseIterable {
    case appVersion, appType, osType, osVersion, apiKey, buildNumber, deviceID, deviceModel

    var value: String {
        switch self {
        case .appVersion:
            return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "9.9.9"
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
            return Bundle.main.infoDictionary?["API_KEY"] as! String
        case .buildNumber:
            return (Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String) ?? "999"
        case .deviceID:
            return UIDevice.current.identifierForVendor?.uuidString ?? ""
        case .deviceModel:
            return UIDevice.current.modelName
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
        case .deviceID:
            return "x-device-id"
        case .deviceModel:
            return "x-device-model"
        }
    }

    static func asDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]
        for metadata in allCases {
            dictionary[metadata.key] = metadata.value
        }
        return dictionary
    }
}

extension DataResponse: @unchecked Sendable {}

final class Logger: EventMonitor {
    let queue = DispatchQueue(label: "NetworkingLog")
    let logStore: NetworkLogStore?

    init(logStore: NetworkLogStore? = nil) {
        self.logStore = logStore
    }

    // Event called when any type of Request is resumed.
    func requestDidResume(_: Request) {}

    // Event called whenever a DataRequest has parsed a response.
    func request<Value>(_: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        Task {
            await logStore?.log(response: response)
        }
    }
}

extension DataTask {
    /// Extract DTO from `DataTask`, or throw error parsed from the response body.
    @discardableResult func handlingError() async throws -> Value {
        if let data = await response.data,
           let errDto = try? JSONDecoder().decode(ErrorDto.self, from: data)
        {
            let errCode = ErrorCode(rawValue: errDto.errcode)
            var requestInfo = await collectRequestInfo()
            requestInfo["ErrorMessage"] = errCode?.errorMessage

            if let errCode, errCode == .SERVER_FAULT {
                Crashlytics.crashlytics().record(error: NSError(domain: errCode.errorTitle, code: errCode.rawValue, userInfo: requestInfo))
            }

            if let displayMessage = errDto.displayMessage {
                throw STError(errCode ?? .SERVER_FAULT, content: displayMessage, detail: errDto.detail)
            } else {
                throw STError(errCode ?? .SERVER_FAULT)
            }
        }

        if let dto = try? await value {
            return dto
        }

        let requestInfo = await collectRequestInfo()
        Crashlytics.crashlytics().record(error: NSError(domain: "UNKNOWN_ERROR", code: -1, userInfo: requestInfo))
        throw STError(.SERVER_FAULT)
    }

    private func collectRequestInfo() async -> [String: Any] {
        var requestInfo: [String: Any] = [:]

        if let requestHeader = await response.request?.headers.description {
            requestInfo["RequestHeader"] = requestHeader
        }

        if let requestBody = await response.request?.httpBody,
           let requestBodyDecoded = String(data: requestBody, encoding: .utf8)
        {
            debugPrint("Error Request Body: \(requestBodyDecoded)")
            requestInfo["RequestBody"] = requestBodyDecoded
        }

        if let responseBody = await response.data,
           let responseBodyDecoded = String(data: responseBody, encoding: .utf8)
        {
            debugPrint("Error Raw Response: \(responseBodyDecoded)")
            requestInfo["ResponseBody"] = responseBodyDecoded
        }

        return requestInfo
    }
}
