//
//  NetworkLogStore.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import Foundation
    import Observation

    @MainActor
    @Observable
    public final class NetworkLogStore {
        public static let shared = NetworkLogStore()

        public private(set) var logs: [NetworkLogEntry] = []
        private let maxLogs = 1000

        private init() {}

        public func addLog(_ log: NetworkLogEntry) {
            logs.insert(log, at: 0)
            if logs.count > maxLogs {
                logs = Array(logs.prefix(maxLogs))
            }
        }

        public func updateLog(id: UUID, response: NetworkLogEntry.Response, duration: TimeInterval) {
            if let index = logs.firstIndex(where: { $0.id == id }) {
                let updatedLog = logs[index]
                logs[index] = NetworkLogEntry(
                    id: updatedLog.id,
                    timestamp: updatedLog.timestamp,
                    request: updatedLog.request,
                    response: response,
                    duration: duration,
                    error: nil
                )
            }
        }

        public func updateLog(id: UUID, error: String) {
            if let index = logs.firstIndex(where: { $0.id == id }) {
                let updatedLog = logs[index]
                logs[index] = NetworkLogEntry(
                    id: updatedLog.id,
                    timestamp: updatedLog.timestamp,
                    request: updatedLog.request,
                    response: nil,
                    duration: nil,
                    error: error
                )
            }
        }

        public func clearLogs() {
            logs.removeAll()
        }
    }
#endif
