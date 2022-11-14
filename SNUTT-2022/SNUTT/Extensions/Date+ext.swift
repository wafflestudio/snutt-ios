//
//  Date+ext.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/07.
//

import Foundation

extension Date {
    func daysFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}
