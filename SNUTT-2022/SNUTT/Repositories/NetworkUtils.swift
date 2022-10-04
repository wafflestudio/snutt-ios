//
//  NetworkUtils.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/08.
//

import Alamofire
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
        
        AdditionalHeaderType.allCases
            .forEach { header in
                urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
            }

        completion(.success(urlRequest))
    }
    
    enum AdditionalHeaderType: String, CaseIterable {
        case appVersion, appType, osType, osVersion, apiKey
        
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
                //TODO: change to NetworkConfiguration
//                return NetworkConfiguration.apiKey
                return Bundle.main.infoDictionary?["API_KEY"] as? String
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
            }
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
        #if DEBUG
            if let requestBody = (await response.request?.httpBody) {
                debugPrint("Error Request Body: \(String(data: requestBody, encoding: .utf8) ?? "")")
            }
            if let responseBody = (await response.data) {
                debugPrint("Error Raw Response: \(String(describing: String(data: responseBody, encoding: .utf8)))")
            }
        #endif
        if let data = await response.data, let errDto = try? JSONDecoder().decode(ErrorDto.self, from: data) {
            throw STError(rawValue: errDto.errcode) ?? .SERVER_FAULT
        }
        throw STError.SERVER_FAULT
    }
}
