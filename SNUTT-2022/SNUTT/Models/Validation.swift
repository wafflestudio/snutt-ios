//
//  Validation.swift
//  SNUTT
//
//  Created by 최유림 on 2022/09/06.
//

import Foundation

struct Validation {
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
        guard let _ = email.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [.regularExpression, .caseInsensitive]) else {
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
