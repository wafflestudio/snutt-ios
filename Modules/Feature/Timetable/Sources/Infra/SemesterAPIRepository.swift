//
//  SemesterAPIRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import TimetableInterface

public struct SemesterAPIRepository: SemesterRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchSemesterStatus() async throws -> SemesterStatus {
        let response = try await apiClient.getSemesterStatus().ok.body.json

        let current = response.current.flatMap { currentDto in
            Quarter(
                year: Int(currentDto.year),
                semester: Semester(rawValue: currentDto.semester.rawValue) ?? .first
            )
        }

        let next = Quarter(
            year: Int(response.next.year),
            semester: Semester(rawValue: response.next.semester.rawValue) ?? .first
        )

        return SemesterStatus(current: current, next: next)
    }
}
