//
//  ValidationUtils.swift
//  SNUTT
//
//  Created by 최유림 on 2022/09/06.
//

import Foundation

struct Validation {
    // RFC 5322
    private static let emailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

    static func check(id: String) -> Bool {
        guard let _ = id.range(of: "^[a-z0-9]{4,32}$", options: [.regularExpression, .caseInsensitive]) else {
            return false
        }
        return true
    }

    static func check(password: String) -> Bool {
        guard let _ = password.range(of: "^(?=.*\\d)(?=.*[a-z])\\S{6,20}$", options: [.regularExpression, .caseInsensitive]) else {
            return false
        }
        return true
    }

    static func check(email: String) -> Bool {
        guard let _ = email.range(of: emailRegex, options: [.regularExpression, .caseInsensitive]) else {
            return false
        }
        return true
    }

    static func check(id _: String, password _: String, check _: String) -> Bool {
        return true
    }

    static func check(password: String, check: String) -> Bool {
        return password == check
    }
}
