//
//  TimetableRepository.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/07.
//

import Alamofire
import Foundation

protocol TimetableRepositoryProtocol {
    func fetchTimetable(withTimetableId: String) async throws -> TimetableDto
    func fetchRecentTimetable() async throws -> TimetableDto
    func fetchTimetableList() async throws -> [TimetableMetadataDto]
    func updateTimetableTitle(withTimetableId id: String, withTitle title: String) async throws -> [TimetableMetadataDto]
    func deleteTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto]
    func copyTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto]
    func updateTimetableTheme(withTimetableId id: String, withTheme theme: Int) async throws -> TimetableDto
}

class TimetableRepository: TimetableRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchTimetable(withTimetableId: String) async throws -> TimetableDto {
        let data = try await session
            .request(TimetableRouter.getTimetable(id: withTimetableId))
            .serializingDecodable(TimetableDto.self)
            .handlingError()
        return data
    }

    func fetchRecentTimetable() async throws -> TimetableDto {
        let data = try await session
            .request(TimetableRouter.getRecentTimetable)
            .serializingDecodable(TimetableDto.self)
            .handlingError()
        return data
    }

    func fetchTimetableList() async throws -> [TimetableMetadataDto] {
        let data = try await session
            .request(TimetableRouter.getTimetableList)
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()

        return data
    }

    func updateTimetableTitle(withTimetableId id: String, withTitle title: String) async throws -> [TimetableMetadataDto] {
        let data = try await session
            .request(TimetableRouter.updateTimetable(id: id, title: title))
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()

        return data
    }

    func deleteTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto] {
        let data = try await session
            .request(TimetableRouter.deleteTimetable(id: id))
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()

        return data
    }

    func copyTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto] {
        let data = try await session
            .request(TimetableRouter.copyTimetable(id: id))
            .serializingDecodable([TimetableMetadataDto].self)
            .handlingError()

        return data
    }

    func updateTimetableTheme(withTimetableId id: String, withTheme theme: Int) async throws -> TimetableDto {
        let data = try await session
            .request(TimetableRouter.updateTheme(id: id, theme: theme))
            .validate()
            .serializingDecodable(TimetableDto.self)
            .handlingError()

        return data
    }
}
