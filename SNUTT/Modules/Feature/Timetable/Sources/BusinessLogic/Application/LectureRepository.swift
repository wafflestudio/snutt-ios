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
}
