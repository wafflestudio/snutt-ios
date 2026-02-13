//
//  PopupLocalRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

protocol PopupLocalRepository: Sendable {
    func fetchPopups() -> [LocalPopup]
    func storePopups(_ popups: [LocalPopup])
}
