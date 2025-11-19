//
//  LectureReminderAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import TimetableInterface

public struct LectureReminderAPIRepository: LectureReminderRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchReminders(timetableID: String) async throws -> [LectureReminder] {
        let response = try await apiClient.getReminders(path: .init(timetableId: timetableID)).ok.body.json
        return response.map { dto in
            LectureReminder(
                timetableLectureID: dto.timetableLectureId,
                lectureTitle: dto.courseTitle,
                option: ReminderOption(from: dto.option)
            )
        }
    }

    public func getReminder(timetableID: String, lectureID: String) async throws -> ReminderOption {
        let response = try await apiClient.getReminder(
            path: .init(timetableId: timetableID, timetableLectureId: lectureID)
        ).ok.body.json
        return ReminderOption(from: response.option)
    }

    public func updateReminder(
        timetableID: String,
        lectureID: String,
        option: ReminderOption
    ) async throws
        -> LectureReminder
    {
        let requestDto = Components.Schemas.TimetableLectureReminderModifyRequestDto(
            option: option.toDTO()
        )
        let response = try await apiClient.modifyReminder(
            path: .init(timetableId: timetableID, timetableLectureId: lectureID),
            body: .json(requestDto)
        ).ok.body.json
        return LectureReminder(
            timetableLectureID: response.timetableLectureId,
            lectureTitle: response.courseTitle,
            option: ReminderOption(from: response.option)
        )
    }
}

// MARK: - DTO Conversion

extension ReminderOption {
    init(from dto: Components.Schemas.TimetableLectureReminderDto.optionPayload) {
        switch dto {
        case .NONE:
            self = .disabled
        case .TEN_MINUTES_BEFORE:
            self = .before10
        case .ZERO_MINUTE:
            self = .onTime
        case .TEN_MINUTES_AFTER:
            self = .after10
        }
    }

    func toDTO() -> Components.Schemas.TimetableLectureReminderModifyRequestDto.optionPayload {
        switch self {
        case .disabled:
            return .NONE
        case .before10:
            return .TEN_MINUTES_BEFORE
        case .onTime:
            return .ZERO_MINUTE
        case .after10:
            return .TEN_MINUTES_AFTER
        }
    }
}
