//
//  Encodable+Dictionary.swift
//  SNUTT
//
//  Created by user on 2/28/25.
//

import Foundation

extension Encodable {
  var dictionary: [String: Any] {
      guard let data = try? JSONEncoder().encode(self) else { return [:] }
      return (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)).flatMap { $0 as? [String: Any] } ?? [:]
  }
}
