//
//  LectureRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import TimetableInterface

@Spyable
public protocol LectureRepository: Sendable {
    typealias LectureBuilding = String
    func fetchBuildingList(places: [LectureBuilding]) async throws -> [Building]
    func updateLecture(timetableID: String, lecture: Lecture, overrideOnConflict: Bool) async throws -> Timetable
    func addCustomLecture(timetableID: String, lecture: Lecture, overrideOnConflict: Bool) async throws -> Timetable
}
