//
//  PopupServerRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Spyable

@Spyable
protocol PopupServerRepository: Sendable {
    func fetchPopups() async throws -> [ServerPopup]
}
