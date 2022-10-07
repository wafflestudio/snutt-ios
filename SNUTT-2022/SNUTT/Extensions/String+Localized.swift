//
//  String+Localized.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/07.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
}
