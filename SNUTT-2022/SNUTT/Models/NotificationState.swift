//
//  NotificationState.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation
import SwiftUI

class NotificationState: ObservableObject {
    @Published var isLoading = false
    @Published var notifications: [STNotification] = []
    @Published var unreadCount: Int = 0

    let perPage: Int = 20
    var pageNum: Int = 0
}
