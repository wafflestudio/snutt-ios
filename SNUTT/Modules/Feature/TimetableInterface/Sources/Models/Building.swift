//
//  Building.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Building: Sendable, Codable, Equatable {
    public let id: String
    public let number: String
    public let nameKor: String
    public let nameEng: String
    public let locationInDMS: Location
    public let locationInDecimal: Location
    @Init(default: Campus.GWANAK) public let campus: Campus
}

public enum Campus: String, Codable, Sendable {
    case GWANAK, YEONGEON, PYEONGCHANG
}

@MemberwiseInit(.public)
public struct Location: Codable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double
}
