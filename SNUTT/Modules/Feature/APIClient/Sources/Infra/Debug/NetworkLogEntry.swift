//
//  NetworkLogEntry.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import Foundation
    import HTTPTypes

    public struct NetworkLogEntry: Identifiable, Sendable {
        public let id: UUID
        public let timestamp: Date
        public let request: Request
        public let response: Response?
        public let duration: TimeInterval?
        public let error: String?

        public init(
            id: UUID = UUID(),
            timestamp: Date = Date(),
            request: Request,
            response: Response? = nil,
            duration: TimeInterval? = nil,
            error: String? = nil
        ) {
            self.id = id
            self.timestamp = timestamp
            self.request = request
            self.response = response
            self.duration = duration
            self.error = error
        }

        public struct Request: Sendable {
            public let method: String
            public let url: String
            public let headers: [String: String]
            public let body: String?

            public init(method: String, url: String, headers: [String: String], body: String?) {
                self.method = method
                self.url = url
                self.headers = headers
                self.body = body
            }
        }

        public struct Response: Sendable {
            public let statusCode: Int
            public let headers: [String: String]
            public let body: String?

            public init(statusCode: Int, headers: [String: String], body: String?) {
                self.statusCode = statusCode
                self.headers = headers
                self.body = body
            }
        }

        // MARK: - Computed Properties

        public var statusColor: String {
            guard let response = response else { return "gray" }
            switch response.statusCode {
            case 200..<300: return "green"
            case 300..<400: return "blue"
            case 400..<500: return "orange"
            case 500..<600: return "red"
            default: return "gray"
            }
        }

        public var summary: String {
            let method = request.method
            let url = request.url
            if let response = response {
                return "\(method) \(url) - \(response.statusCode)"
            } else if let error = error {
                return "\(method) \(url) - Error: \(error)"
            } else {
                return "\(method) \(url) - Pending"
            }
        }

        public var formattedDuration: String {
            guard let duration = duration else { return "N/A" }
            return String(format: "%.2f ms", duration * 1000)
        }

        public func matches(searchText: String) -> Bool {
            guard !searchText.isEmpty else { return true }
            let lowercased = searchText.lowercased()

            return request.url.lowercased().contains(lowercased) || request.method.lowercased().contains(lowercased)
                || (response?.statusCode.description.contains(lowercased) ?? false)
                || (request.body?.lowercased().contains(lowercased) ?? false)
                || (response?.body?.lowercased().contains(lowercased) ?? false)
        }
    }
#endif
