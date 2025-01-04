//
//  NetworkLogStore.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/09.
//

import Alamofire
import Combine
import Foundation

@MainActor
class NetworkLogStore {
    @Published private(set) var logs: [NetworkLogEntry] = []

    private let maxLogEntries = 10000

    func log<Value>(response: DataResponse<Value, AFError>) {
        guard let urlRequest = response.request else { return }
        let urlResponse = response.response
        let logEntry = NetworkLogEntry(id: UUID(),
                                       url: urlRequest.url,
                                       statusCode: urlResponse?.statusCode ?? 0,
                                       httpMethod: urlRequest.httpMethod,
                                       requestHeaders: urlRequest.headers,
                                       responseHeaders: urlResponse?.headers ?? [:],
                                       requestData: urlRequest.httpBody,
                                       responseData: response.data,
                                       metrics: response.metrics)
        logs.append(logEntry)
        rotateLogsIfNeeded()
    }

    private func rotateLogsIfNeeded() {
        if logs.count > maxLogEntries {
            logs.removeFirst(logs.count - maxLogEntries)
        }
    }

    func reset() {
        logs.removeAll()
    }
}
