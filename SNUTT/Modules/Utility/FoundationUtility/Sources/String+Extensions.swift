//
//  String+Extensions.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

extension String {
    public var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    /// Transform `String` into `AttributedString` supporting markdown
    public func asMarkdown() -> AttributedString {
        (try? AttributedString(markdown: self, options: .init(interpretedSyntax: .inlineOnly)))
            ?? AttributedString(stringLiteral: self)
    }
}

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case let .some(value):
            return value.isEmpty
        }
    }
}
