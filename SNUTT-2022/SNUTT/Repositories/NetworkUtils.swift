//
//  NetworkUtils.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/08.
//

import Alamofire
import Foundation

/// 적절한 장소로 옮겨야
protocol AuthStorage {
    typealias ApiKey = String
    typealias AccessToken = String
    var apiKey: ApiKey { get set }
    var accessToken: AccessToken { get set }
}

final class Interceptor: RequestInterceptor {
    private let authStorage: AuthStorage

    init(authStorage: AuthStorage) {
        self.authStorage = authStorage
    }

    func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        urlRequest.setValue(authStorage.apiKey, forHTTPHeaderField: "x-access-apikey")
        urlRequest.setValue(authStorage.accessToken, forHTTPHeaderField: "x-access-token")

        completion(.success(urlRequest))
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
            debugPrint("Error Raw Response: \(String(describing: String(data: await response.data!, encoding: .utf8)))")
        #endif
        if let data = await response.data, let errDto = try? JSONDecoder().decode(ErrorDto.self, from: data) {
            throw STError(rawValue: errDto.errcode) ?? .SERVER_FAULT
        }
        throw STError.SERVER_FAULT
    }
}
