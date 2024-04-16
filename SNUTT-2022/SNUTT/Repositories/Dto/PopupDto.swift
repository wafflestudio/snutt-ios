//
//  PopupDto.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Foundation

struct PopupResponseDto: Decodable {
    let content: [PopupDto]
}

struct PopupDto: Decodable {
    let key: String
    let imageUri: String
    let hiddenDays: Int?
}

struct PopupMetadata: Codable {
    let key: String
    let hiddenDays: Int?
    let dismissedAt: Date?
    let dontShowForWhile: Bool?
}

extension PopupMetadata {
    init(from model: Popup) {
        key = model.id
        hiddenDays = model.hiddenDays
        dismissedAt = model.dismissedAt
        dontShowForWhile = model.dontShowForWhile
    }
}
