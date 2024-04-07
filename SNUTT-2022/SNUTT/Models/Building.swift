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
        self.id = dto.id
        self.number = dto.buildingNumber
        self.nameKor = dto.buildingNameKor
        self.nameEng = dto.buildingNameEng
        self.locationInDMS = dto.locationInDMS
        self.locationInDecimal = dto.locationInDecimal
        self.campus = .init(rawValue: dto.campus) ?? .GWANAK
    }
}
