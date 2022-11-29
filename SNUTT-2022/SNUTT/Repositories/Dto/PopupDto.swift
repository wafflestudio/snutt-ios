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
    let key: String
    let image_url: String
    let hidden_days: Int?
    let dismissed_at: Date?
    let dont_show_for_while: Bool?
}

extension PopupDto {
    init(from model: Popup) {
        key = model.id
        image_url = model.imageURL
        hidden_days = model.hiddenDays
        dismissed_at = model.dismissedAt
        dont_show_for_while = model.dontShowForWhile
    }
}
