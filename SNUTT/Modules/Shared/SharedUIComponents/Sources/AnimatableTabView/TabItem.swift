//
//  TabItem.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import UIKit

public protocol TabItem: Hashable {
    var isSearchRole: Bool { get }
    func image(isSelected: Bool) -> UIImage
    func viewIndex() -> Int
}
