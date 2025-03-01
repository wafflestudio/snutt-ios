//
//  SnakeCaseConvertible.swift
//  SNUTT
//
//  Created by user on 2/28/25.
//

import Foundation

protocol SnakeCaseConvertible {
    var snakeCase: String { get }
}

extension SnakeCaseConvertible {
    var snakeCase: String {
        return snakeCased(caseName)
    }

    private var caseName: String {
        Mirror(reflecting: self).children.first?.label ?? "\(self)"
    }

    private func snakeCased(_ string: String) -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let fullWordsPattern = "([a-z])([A-Z]|[0-9])"
        let digitsFirstPattern = "([0-9])([A-Z])"
        return string.processCamelCaseRegex(pattern: acronymPattern)?
          .processCamelCaseRegex(pattern: fullWordsPattern)?
          .processCamelCaseRegex(pattern:digitsFirstPattern)?.lowercased() ?? string.lowercased()
    }
}


extension String {
    fileprivate func processCamelCaseRegex(pattern: String) -> String? {
      let regex = try? NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: count)
      return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}
