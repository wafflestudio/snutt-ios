//
//  TimetableRepository.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/07.
//

import Alamofire
import Foundation

protocol TimetableRepositoryProtocol {
    func fetchTimetable(timetableId: String) async throws -> TimetableDto
    func fetchRecentTimetable() async throws -> TimetableDto
    func fetchTimetableList() async throws -> [TimetableMetadataDto]
    func fetchTimetable(withTimetableId id: String) async throws -> TimetableDto
    func updateTimetableTitle(withTimetableId id: String, withTitle title: String) async throws -> [TimetableMetadataDto]
    func deleteTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto]
    func copyTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto]
    func updateTimetableTheme(withTimetableId id: String, withTheme theme: Int) async throws -> TimetableDto
    func createTimetable(title: String, year: Int, semester: Int) async throws -> [TimetableMetadataDto]
}

class TimetableRepository: TimetableRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchTimetable(timetableId: String) async throws -> TimetableDto {
        return try await session
            .request(TimetableRouter.getTimetable(id: timetableId))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func fetchRecentTimetable() async throws -> TimetableDto {
        return try await session
            .request(TimetableRouter.getRecentTimetable)
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func fetchTimetableList() async throws -> [TimetableMetadataDto] {
        return try await session
            .request(TimetableRouter.getTimetableList)
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()
    }

    func fetchTimetable(withTimetableId id: String) async throws -> TimetableDto {
        return try await session
            .request(TimetableRouter.getTimetable(id: id))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }

    func createTimetable(title: String, year: Int, semester: Int) async throws -> [TimetableMetadataDto] {
        return try await session
            .request(TimetableRouter.createTimetable(title: title, year: year, semester: semester))
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()
    }

    func updateTimetableTitle(withTimetableId id: String, withTitle title: String) async throws -> [TimetableMetadataDto] {
        return try await session
            .request(TimetableRouter.updateTimetable(id: id, title: title))
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()
    }

    func deleteTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto] {
        return try await session
            .request(TimetableRouter.deleteTimetable(id: id))
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()
    }

    func copyTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto] {
        return try await session
            .request(TimetableRouter.copyTimetable(id: id))
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()
    }

    func updateTimetableTheme(withTimetableId id: String, withTheme theme: Int) async throws -> TimetableDto {
        return try await session
            .request(TimetableRouter.updateTheme(id: id, theme: theme))
            .validate()
            .serializingDecodable(TimetableDto.self)
            .handlingError()
    }
}
