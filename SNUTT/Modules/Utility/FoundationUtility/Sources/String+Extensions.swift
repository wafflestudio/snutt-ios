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
        try! AttributedString(markdown: self, options: .init(interpretedSyntax: .inlineOnly))
    }
}
