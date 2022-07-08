//
//  TimetableRepository.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/07.
//

import Alamofire
import Foundation

protocol TimetableRepositoryProtocol {
    func fetchRecentTimetable() async throws -> TimetableDto
    func fetchTimetableList() async throws -> [TimetableMetadataDto]
    func fetchTimetable(withTimetableId id: String) async throws -> TimetableDto
    func updateTimetableTitle(withTimetableId id: String, withTitle title: String) async throws -> [TimetableMetadataDto]
    func deleteTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto]
    func copyTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto]
    func updateTimetableTheme(withTimetableId id: String, withTheme theme: Int) async throws -> [TimetableMetadataDto]
}

class TimetableRepository: TimetableRepositoryProtocol {
    private let session: Session

    init(interceptor: RequestInterceptor, eventMonitors: [EventMonitor]) {
        session = Session(interceptor: interceptor, eventMonitors: eventMonitors)
    }

    func fetchRecentTimetable() async throws -> TimetableDto {
        let data = try await session.request(TimetableRouter.getRecentTimetable).validate().serializingDecodable(TimetableDto.self).value

        return data
    }

    func fetchTimetableList() async throws -> [TimetableMetadataDto] {
        let data = try await session.request(TimetableRouter.getTimetableList).validate().serializingDecodable([TimetableMetadataDto].self).value

        return data
    }

    func fetchTimetable(withTimetableId id: String) async throws -> TimetableDto {
        let data = try await session.request(TimetableRouter.getTimetable(id: id)).validate().serializingDecodable(TimetableDto.self).value

        return data
    }

    func updateTimetableTitle(withTimetableId id: String, withTitle title: String) async throws -> [TimetableMetadataDto] {
        let data = try await session.request(TimetableRouter.updateTimetable(id: id, title: title)).validate().serializingDecodable([TimetableMetadataDto].self).value

        return data
    }

    func deleteTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto] {
        let data = try await session.request(TimetableRouter.deleteTimetable(id: id)).validate().serializingDecodable([TimetableMetadataDto].self).value

        return data
    }

    func copyTimetable(withTimetableId id: String) async throws -> [TimetableMetadataDto] {
        let data = try await session.request(TimetableRouter.copyTimetable(id: id)).validate().serializingDecodable([TimetableMetadataDto].self).value

        return data
    }

    func updateTimetableTheme(withTimetableId id: String, withTheme theme: Int) async throws -> [TimetableMetadataDto] {
        let data = try await session.request(TimetableRouter.updateTheme(id: id, theme: theme)).validate().serializingDecodable([TimetableMetadataDto].self).value

        return data
    }
}
