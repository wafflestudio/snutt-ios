//
//  PopupServerRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Spyable

@Spyable
protocol PopupServerRepository: Sendable {
    func fetchPopups() async throws -> [ServerPopup]
}
