//
//  DateFormatter+Parse.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation

extension DateFormatter {
    static func parse(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter.date(from: string)
    }
    
    static func parse(date: Date?, format: String = "yyyy/MM/dd") -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
