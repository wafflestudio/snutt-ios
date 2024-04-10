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
    let imageUri: String
    let hiddenDays: Int?
    let dismissedAt: Date?
    let dontShowForWhile: Bool?
}

extension PopupDto {
    init(from model: Popup) {
        key = model.id
        imageUri = model.imageURL
        hiddenDays = model.hiddenDays
        dismissedAt = model.dismissedAt
        dontShowForWhile = model.dontShowForWhile
    }

    init(from metadata: PopupMetadata, imageUri: String) {
        key = metadata.key
        hiddenDays = metadata.hiddenDays
        dismissedAt = metadata.dismissedAt
        dontShowForWhile = metadata.dontShowForWhile
        self.imageUri = imageUri
    }
}

struct PopupMetadata: Codable {
    let key: String
    let hiddenDays: Int?
    let dismissedAt: Date?
    let dontShowForWhile: Bool?
}
