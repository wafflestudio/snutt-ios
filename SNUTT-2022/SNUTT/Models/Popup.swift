//
//  Popup.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import Foundation

struct Popup {
    let id: String
    let imageURL: String
    let hiddenDays: Int
    var lastUpdate: Date?
}

extension Popup: Equatable {
    static func ==(lhs: Popup, rhs: Popup) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Popup: Identifiable {
    
}

extension Popup {
    init(from dto: PopupDto) {
        id = dto.key ?? ""
        imageURL = dto.image_url ?? ""
        hiddenDays = dto.hidden_days ?? 0
        lastUpdate = dto.last_update ?? nil
    }
}
