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

    public func fetchBuildingList(places: String) async throws -> [Building] {
        let response = try await apiClient.searchBuildings(query: .init(places: places)).ok.body.json.content
        return response.compactMap { Building(dto: $0) }
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
