//
//  DebugNetworkLoggingMiddleware.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import Foundation
    import HTTPTypes
    import OpenAPIRuntime

    public struct DebugNetworkLoggingMiddleware: ClientMiddleware {
        public init() {}

        public func intercept(
            _ request: HTTPRequest,
            body: HTTPBody?,
            baseURL: URL,
            operationID _: String,
            next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
        ) async throws -> (HTTPResponse, HTTPBody?) {
            let logID = UUID()
            let startTime = Date()

            // Capture request details
            let requestURL = buildFullURL(baseURL: baseURL, request: request)
            let requestHeaders = extractHeaders(from: request.headerFields)
            let requestBody = await extractBody(from: body)

            let requestLog = NetworkLogEntry.Request(
                method: request.method.rawValue,
                url: requestURL,
                headers: requestHeaders,
                body: requestBody
            )

            // Create initial log entry
            let initialEntry = NetworkLogEntry(
                id: logID,
                timestamp: startTime,
                request: requestLog
            )

            // Add to store
            await NetworkLogStore.shared.addLog(initialEntry)

            // Execute request
            do {
                let (response, responseBody) = try await next(request, body, baseURL)
                let duration = Date().timeIntervalSince(startTime)

                // Capture response details
                let responseData = try await Data(collecting: responseBody!, upTo: .max)
                let responseHeaders = extractHeaders(from: response.headerFields)
                let responseBodyString = extractBodyString(from: responseData)

                let responseLog = NetworkLogEntry.Response(
                    statusCode: response.status.code,
                    headers: responseHeaders,
                    body: responseBodyString
                )

                // Update log entry with response
                await NetworkLogStore.shared.updateLog(id: logID, response: responseLog, duration: duration)

                return (response, HTTPBody(responseData))
            } catch {
                // Update log entry with error
                await NetworkLogStore.shared.updateLog(id: logID, error: error.localizedDescription)

                throw error
            }
        }

        // MARK: - Helper Methods

        private func buildFullURL(baseURL: URL, request: HTTPRequest) -> String {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            components?.path = request.path ?? ""
            return components?.url?.absoluteString ?? baseURL.absoluteString
        }

        private func extractHeaders(from headerFields: HTTPFields) -> [String: String] {
            var headers: [String: String] = [:]
            for field in headerFields {
                headers[field.name.rawName] = field.value
            }
            return headers
        }

        private func extractBody(from body: HTTPBody?) async -> String? {
            guard let body = body else { return nil }

            do {
                let data = try await Data(collecting: body, upTo: .max)
                return extractBodyString(from: data)
            } catch {
                return "Failed to extract body: \(error.localizedDescription)"
            }
        }

        private func extractBodyString(from data: Data) -> String? {
            guard !data.isEmpty else { return nil }

            // Try to parse as JSON for pretty printing
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                let prettyString = String(data: prettyData, encoding: .utf8)
            {
                return prettyString
            }

            // Fallback to plain string
            return String(data: data, encoding: .utf8) ?? "Binary data (\(data.count) bytes)"
        }
    }
#endif
