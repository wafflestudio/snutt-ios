//
//  Codable+Extension.swift
//  SNUTT
//
//  Created by Rajin on 2019. 1. 1..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
