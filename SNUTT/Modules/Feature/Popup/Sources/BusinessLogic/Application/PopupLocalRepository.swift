//
//  PopupLocalRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

protocol PopupLocalRepository: Sendable {
    func fetchPopups() -> [LocalPopup]
    func storePopups(_ popups: [LocalPopup])
}
