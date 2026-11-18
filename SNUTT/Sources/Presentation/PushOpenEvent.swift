//
//  PushOpenEvent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface

/// Logged once per notification tap. Join with the server's `push_history` on `push_id` to see the push type.
struct PushOpenEvent: AnalyticsLogEvent {
    /// Missing for pushes sent by older servers.
    let pushID: String?
    /// Host and path of `url_scheme`. The query is dropped because it may carry lecture titles.
    let path: String?

    init(userInfo: [AnyHashable: Any]) {
        pushID = (userInfo[Keys.pushID] as? String).flatMap { $0.isEmpty ? nil : $0 }
        path = (userInfo[Keys.urlScheme] as? String).flatMap(Self.extractPath)
    }

    var eventName: String { "push_open" }

    var parameters: [String: String]? {
        var parameters = [String: String]()
        parameters["push_id"] = pushID
        parameters["path"] = path
        return parameters
    }

    /// `snutt://diary?lectureId=..` → `diary`, `https://host/a/b?x=1#y` → `host/a/b`
    static func extractPath(from urlScheme: String) -> String? {
        var rest = Substring(urlScheme)
        if let range = rest.range(of: "://") {
            rest = rest[range.upperBound...]
        }
        if let index = rest.firstIndex(where: { $0 == "?" || $0 == "#" }) {
            rest = rest[..<index]
        }
        while rest.hasSuffix("/") {
            rest = rest.dropLast()
        }
        return rest.isEmpty ? nil : String(rest)
    }

    enum Keys {
        static let pushID = "push_id"
        static let urlScheme = "url_scheme"
    }
}
