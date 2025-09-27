//
//  MenuItem.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import SwiftUI

protocol MenuItem: Hashable {
    var title: String { get }
    var leadingImage: Image? { get }
    var detail: String? { get }
    var detailImage: Image? { get }
    var destructive: Bool { get }
    var shouldNavigate: Bool { get }
}

enum Destination: Hashable {
    case settings(Settings)
    case myAccount(MyAccount)
}
