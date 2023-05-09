//
//  NetworkLogEntry.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/09.
//

import Foundation
import Alamofire


struct NetworkLogEntry: Identifiable, Sendable {
    let id: UUID
    var url: URL?
    var statusCode: Int
    var httpMethod: String?
    var requestHeaders: HTTPHeaders
    var responseHeaders: HTTPHeaders
    var requestData: Data?
    var responseData: Data?
}

extension Data {
    func jsonFormatted() -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) else {
            return String(data: self, encoding: .utf8)
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension HTTPHeaders: @unchecked Sendable {}

extension NetworkLogEntry {
    static func createFixture() -> Self {
        let headers = HTTPHeaders([.init(name: "x-access-key", value: "f29fba4ba83"), .init(name: "x-api-token", value: "fwaiofawefaweifa")])
        return NetworkLogEntry(id: UUID(), url: URL(string: "www.naver.com"), statusCode: 200, httpMethod: "POST", requestHeaders: headers, responseHeaders: headers, responseData: nil)
    }
}
