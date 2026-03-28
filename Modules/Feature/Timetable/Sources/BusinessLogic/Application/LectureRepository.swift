//
//  LectureRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import TimetableInterface

@Spyable
public protocol LectureRepository: Sendable {
    typealias LectureBuilding = String
    func fetchBuildingList(places: [LectureBuilding]) async throws -> [Building]
    func updateLecture(timetableID: TimetableID, lecture: Lecture, overrideOnConflict: Bool) async throws -> Timetable
    func addCustomLecture(
        timetableID: TimetableID,
        lecture: Lecture,
        overrideOnConflict: Bool
    ) async throws -> Timetable
    func resetLecture(timetableID: TimetableID, lectureID: TimetableLectureID) async throws -> Timetable
    func addBookmark(lectureID: LectureID) async throws
    func removeBookmark(lectureID: LectureID) async throws
    func isBookmarked(lectureID: LectureID) async throws -> Bool
    func fetchBookmarks(quarter: Quarter) async throws -> [Lecture]
}
