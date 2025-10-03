//
//  SemesterDto.swift
//  SNUTT
//
//  Created by 최유림 on 10/3/25.
//

import Foundation

struct SemesterInfo: Decodable {
    let year: Int
    let semester: Int
}

struct SemesterStatusDto: Decodable {
    let current: SemesterInfo?
    let next: SemesterInfo
}
