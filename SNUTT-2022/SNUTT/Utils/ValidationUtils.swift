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
    
    /// 영문과 숫자 모두 포함
    private static let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9]+$"

    static func check(email: String) -> Bool {
        guard let _ = email.range(of: emailRegex, options: [.regularExpression, .caseInsensitive]) else {
            return false
        }
        return true
    }
    
    /// 영문, 숫자 모두 포함 6-20자 이내
    static func check(password: String) -> Bool {
        if password.count < 6 || password.count > 20 {
            return false
        }
        guard let _ = password.range(of: passwordRegex, options: [.regularExpression]) else {
            return false
        }
        return true
    }
}
