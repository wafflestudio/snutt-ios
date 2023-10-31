//
//  SearchTagDto.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation

struct SearchTagListDto: Codable {
    var classification: [String]
    var department: [String]
    var academic_year: [String]
    var credit: [String]
    var category: [String]
    var etc: [String]? // not given from server
    var updated_at: Int64
}
