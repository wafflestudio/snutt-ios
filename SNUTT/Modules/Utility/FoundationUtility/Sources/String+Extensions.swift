//
//  String+Extensions.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

extension String {
    public var emptyToNil: String? {
        isEmpty ? nil : self
    }
}
