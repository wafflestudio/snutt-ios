//
//  STQuarter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

struct STQuarter: DictionaryRepresentable {
    var year: Int
    var semester: STSemester

    init(year: Int, semester: STSemester) {
        self.year = year
        self.semester = semester
    }

    func shortString() -> String {
        return String(year) + semester.shortString()
    }

    func longString() -> String {
        return String(year) + " " + semester.longString()
    }

    func dictionaryValue() -> NSDictionary {
        let representation: [String: Any] = ["year": year, "semester": semester.rawValue]
        return representation as NSDictionary
    }

    init?(dictionary: NSDictionary?) {
        guard let values = dictionary else { return nil }
        if let year = values["year"] as? Int,
           let semester = STSemester(raw: values["semester"] as? Int)
        {
            self.year = year
            self.semester = semester
        } else {
            return nil
        }
    }
}

extension STQuarter: Equatable, Comparable {}

func == (lhs: STQuarter, rhs: STQuarter) -> Bool {
    return lhs.year == rhs.year && lhs.semester == rhs.semester
}

func < (lhs: STQuarter, rhs: STQuarter) -> Bool {
    return lhs.year < rhs.year || (lhs.year == rhs.year && lhs.semester < rhs.semester)
}
