//
//  LectureAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import TimetableInterface

public struct LectureAPIRepository: LectureRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchBuildingList(places: [LectureBuilding]) async throws -> [Building] {
        let joinedPlaces = places.joined(separator: ",")
        let response = try await apiClient.searchBuildings(query: .init(places: joinedPlaces)).ok.body.json.content
        return response.compactMap { Building(dto: $0) }
    }

    public func updateLecture(timetableID: String, lecture: Lecture, overrideOnConflict: Bool) async throws -> Timetable {
        guard let lectureID = lecture.lectureID else { throw LocalizedErrorCode.lectureNotFound }
        let timePlaces = try lecture.timePlaces
            .map {
                try Components.Schemas.ClassPlaceAndTimeLegacyRequestDto(
                    day: require(.init(rawValue: $0.day.rawValue)),
                    endMinute: Int32($0.endTime.absoluteMinutes),
                    place: $0.place,
                    startMinute: Int32($0.startTime.absoluteMinutes)
                )
            }
        let requestDto = Components.Schemas.TimetableLectureModifyLegacyRequestDto(
            academic_year: lecture.academicYear,
            category: lecture.category,
            categoryPre2025: lecture.categoryPre2025,
            class_time_json: timePlaces,
            classification: lecture.classification,
            color: lecture.customColor.flatMap({ .init(bg: $0.bgHex, fg: $0.fgHex) }),
            colorIndex: Int32(lecture.colorIndex),
            course_title: lecture.courseTitle,
            credit: lecture.credit,
            instructor: lecture.instructor,
            is_forced: overrideOnConflict,
            remark: lecture.remark
        )
        return try await apiClient.modifyTimetableLecture(
            path: .init(timetableId: timetableID, timetableLectureId: lectureID),
            query: .init(isForced: overrideOnConflict.description),
            body: .json(requestDto)
        ).ok.body.json.toTimetable()
    }
}

extension Building {
    init?(dto: Components.Schemas.LectureBuilding) {
        guard let id = dto.id,
              let locationInDecimal = dto.locationInDecimal,
              let locationInDMS = dto.locationInDMS
        else {
            return nil
        }
        self.init(
            id: id,
            number: dto.buildingNumber,
            nameKor: dto.buildingNameKor,
            nameEng: dto.buildingNameEng,
            locationInDMS: .init(
                latitude: locationInDMS.latitude,
                longitude: locationInDMS.longitude
            ),
            locationInDecimal: .init(
                latitude: locationInDecimal.latitude,
                longitude: locationInDecimal.longitude
            ),
            campus: .init(rawValue: dto.campus.rawValue) ?? .GWANAK
        )
    }
}
