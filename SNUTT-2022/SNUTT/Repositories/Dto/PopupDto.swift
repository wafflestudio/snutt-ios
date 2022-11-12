//
//  PopupDto.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Foundation

struct PopupResponseDto: Codable {
    let content: [PopupDto]
}

struct PopupDto: Codable {
    let key: String?
    let image_url: String?
    let hidden_days: Int?
    let last_update: Date?
}

extension PopupDto {
    init(from model: Popup) {
        key = model.id
        image_url = model.imageURL
        hidden_days = model.hiddenDays
        last_update = model.lastUpdate
    }
}
