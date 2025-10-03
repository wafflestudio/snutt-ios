//
//  LectureRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire
import Foundation

protocol LectureRepositoryProtocol {
    func addLecture(timetableId: String, lectureId: String, isForced: Bool) async throws -> TimetableDto
    func addCustomLecture(timetableId: String, lecture: LectureDto, isForced: Bool) async throws -> TimetableDto
    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto, isForced: Bool) async throws -> TimetableDto
    func deleteLecture(timetableId: String, lectureId: String) async throws -> TimetableDto
    func resetLecture(timetableId: String, lectureId: String) async throws -> TimetableDto
    func getBuildingList(places: String) async throws -> BuildingListDto

    // MARK: Bookmark
    
    func getBookmark(quarter: Quarter) async throws -> BookmarkDto
    func bookmarkLecture(lectureId: String) async throws
    func undoBookmarkLecture(lectureId: String) async throws
    
    // MARK: Lecture Reminder
    
    func fetchLectureReminderList(timetableId: String) async throws -> [LectureReminderDto]
    func getLectureReminderState(timetableId: String, lectureId: String) async throws -> LectureReminderDto
    func changeLectureReminderState(timetableId: String, lectureId: String, to offset: Int) async throws -> LectureReminderDto
    func deleteLectureReminder(timetableId: String, lectureId: String) async throws
}

class LectureRepository: LectureRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func addLecture(timetableId: String, lectureId: String, isForced: Bool) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.addLecture(timetableId: timetableId, lectureId: lectureId, isForced: isForced))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func addCustomLecture(timetableId: String, lecture: LectureDto, isForced: Bool) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.addCustomLecture(timetableId: timetableId, lecture: lecture, isForced: isForced))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func deleteLecture(timetableId: String, lectureId: String) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.deleteLecture(timetableId: timetableId, lectureId: lectureId))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto, isForced: Bool) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.updateLecture(timetableId: timetableId, oldLecture: oldLecture, newLecture: newLecture, isForced: isForced))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func resetLecture(timetableId: String, lectureId: String) async throws -> TimetableDto {
        return try await session
            .request(LectureRouter.resetLecture(timetableId: timetableId, lectureId: lectureId))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }
    
    func getBuildingList(places: String) async throws -> BuildingListDto {
        return try await session
            .request(BuildingRouter.getBuildingInfo(places: places))
            .serializingDecodable(BuildingListDto.self)
            .handlingError()
    }
    
    // MARK: Lecture Reminder
    
    func fetchLectureReminderList(timetableId: String) async throws -> [LectureReminderDto] {
        try await session
            .request(LectureReminderRouter.getReminderList(timetableId: timetableId))
            .serializingDecodable([LectureReminderDto].self)
            .handlingError()
    }
    
    func getLectureReminderState(timetableId: String, lectureId: String) async throws -> LectureReminderDto {
        try await session
            .request(LectureReminderRouter.getReminderState(timetableId: timetableId, lectureId: lectureId))
            .serializingDecodable(LectureReminderDto.self)
            .handlingError()
    }
    
    func changeLectureReminderState(timetableId: String, lectureId: String, to offset: Int) async throws -> LectureReminderDto {
        try await session
            .request(LectureReminderRouter.changeReminderState(timetableId: timetableId, lectureId: lectureId, offset: offset))
            .serializingDecodable(LectureReminderDto.self)
            .handlingError()
    }
    
    func deleteLectureReminder(timetableId: String, lectureId: String) async throws {
        try await session
            .request(LectureReminderRouter.deleteReminder(timetableId: timetableId, lectureId: lectureId))
            .serializingString()
            .handlingError()
    }
    
    // MARK: Bookmark

    func getBookmark(quarter: Quarter) async throws -> BookmarkDto {
        return try await session
            .request(BookmarkRouter.getBookmark(quarter: quarter))
            .serializingDecodable(BookmarkDto.self)
            .handlingError()
    }

    func bookmarkLecture(lectureId: String) async throws {
        let _ = try await session
            .request(BookmarkRouter.bookmarkLecture(lectureId: lectureId))
            .serializingString(emptyResponseCodes: [200])
            .handlingError()
    }

    func undoBookmarkLecture(lectureId: String) async throws {
        let _ = try await session
            .request(BookmarkRouter.undoBookmarkLecture(lectureId: lectureId))
            .serializingString(emptyResponseCodes: [200])
            .handlingError()
    }
}
