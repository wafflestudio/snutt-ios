//
//  MapLocation.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import MapKit

public struct MapLocation: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public let latitude: Double
    public let longitude: Double
    public let label: String

    public init(latitude: Double, longitude: Double, label: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.label = label
        self.id = "\(latitude),\(longitude),\(label)"
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
