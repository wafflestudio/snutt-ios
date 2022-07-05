//
//  Lecture.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

struct Lecture: Codable, Identifiable {
    let id: Int
    let title: String
    let instructor: String
    let timePlaces: [TimePlace]
}
