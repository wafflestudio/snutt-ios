//
//  TabItem.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import UIKit

public protocol TabItem: Hashable {
    func image(isSelected: Bool) -> UIImage
    func viewIndex() -> Int
}
