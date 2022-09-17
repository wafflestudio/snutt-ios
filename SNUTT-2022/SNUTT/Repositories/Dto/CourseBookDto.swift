//
//  CourseBookDto.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/19.
//

import Foundation

struct CourseBookDto: Codable {
    var year: Int
    var semester: Int
    var updated_at: String
}

struct SyllabusDto: Codable {
    var url: String
}
