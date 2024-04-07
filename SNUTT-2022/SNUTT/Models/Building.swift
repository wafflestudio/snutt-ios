//
//  Building.swift
//  SNUTT
//
//  Created by 최유림 on 2024/01/24.
//

import Foundation

struct Building {
    let id: String
    let number: String
    let nameKor: String
    let nameEng: String
    let locationInDMS: Location
    let locationInDecimal: Location
    let campus: Campus
}

extension Building {
    init(from dto: BuildingDto) {
        id = dto.id
        number = dto.buildingNumber
        nameKor = dto.buildingNameKor
        nameEng = dto.buildingNameEng
        locationInDMS = dto.locationInDMS
        locationInDecimal = dto.locationInDecimal
        campus = .init(rawValue: dto.campus) ?? .GWANAK
    }
}
