//
//  AttributedString+Init.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import UIKit

extension AttributedString {
    public init(_ string: String, font: UIFont? = nil) {
        if let font {
            self.init(string, attributes: .init([.font: font]))
        } else {
            self.init(string, attributes: .init([:]))
        }
    }
}
