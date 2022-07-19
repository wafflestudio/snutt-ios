//
//  LectureRepositoryTests.swift
//  SNUTTTests
//
//  Created by 박신홍 on 2022/07/19.
//

import Alamofire
import XCTest

class LectureRepositoryTests: XCTestCase {
    class Storage: AuthStorage {
        var apiKey: ApiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdHJpbmciOiJpb3MiLCJrZXlfdmVyc2lvbiI6IjAiLCJpYXQiOjE1MDc3MjM3MDd9.wlhtBwB2e9A4qzA7PdjR-NdER2O_jajPCzlMhcREpig"
        var accessToken: AccessToken = "c7f446a24b74178c583dd915b449a4285197d355dce5e4426605a64eb2133fbd"
    }

    func testExtractModifiedMethod() {
        let oldLecture: LectureDto = .init(_id: "33", classification: "343", department: "3433", academic_year: "4334", course_title: "444", credit: 4, class_time: "444", class_time_json: [.init(_id: "032", day: 3, start: 0.5, len: 2.3, place: "hello")], class_time_mask: [], instructor: "443", quota: 40, remark: "444", category: "434", course_number: "44", lecture_number: "34", created_at: "", updated_at: "", color: ["gf": "ff"], colorIndex: 3)
        let newLecture: LectureDto = .init(_id: "33", classification: "3433", department: "3433", academic_year: "4334", course_title: "444", credit: 4, class_time: "444", class_time_json: [.init(_id: "032", day: 3, start: 0.5, len: 2.3, place: "hello1")], class_time_mask: [], instructor: "4433", quota: 40, remark: "444", category: "434", course_number: "44", lecture_number: "34", created_at: "", updated_at: "", color: ["gf": "ff1"], colorIndex: 3)
        let ret = oldLecture.extractModified(in: newLecture)
        XCTAssertEqual(ret["instructor"] as? String, "4433")
        XCTAssertNil(ret["department"])
        XCTAssertEqual(ret["color"] as? [String: String], ["gf": "ff1"])
        XCTAssertNotNil(ret["class_time_json"])
    }
}
