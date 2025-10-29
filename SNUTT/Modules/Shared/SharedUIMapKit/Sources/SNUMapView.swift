//
//  SNUMapView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import MapKit
import SwiftUI

public struct SNUMapView: View {
    let locations: [MapLocation]
    let onLocationTap: ((MapLocation) -> Void)?

    @State private var position: MapCameraPosition
    @State private var selectedLocation: MapLocation?

    public init(
        locations: [MapLocation],
        onLocationTap: ((MapLocation) -> Void)? = nil
    ) {
        self.locations = locations
        self.onLocationTap = onLocationTap
        _position = State(initialValue: Self.calculateInitialPosition(for: locations))
    }

    public var body: some View {
        Map(position: $position, selection: $selectedLocation) {
            MapPolygon(coordinates: Self.campusBoundary)
                .foregroundStyle(.blue.opacity(0.1))
                .stroke(.blue, lineWidth: 1)

            // Landmarks as Annotation (background context)
            ForEach(MapLocation.predefinedLandmarks) { landmark in
                Annotation(landmark.label, coordinate: landmark.coordinate) {
                    EmptyView()
                }
            }

            // Locations as Marker (prominent, interactive)
            ForEach(locations) { location in
                Marker(location.label, coordinate: location.coordinate)
                    .tag(location)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including(.university, .store, .restaurant)))
        .onChange(of: selectedLocation) { _, newValue in
            if let location = newValue {
                onLocationTap?(location)
            }
        }
        .onChange(of: locations) { _, newValue in
            position = Self.calculateInitialPosition(for: newValue)
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }

    private static func calculateInitialPosition(for locations: [MapLocation]) -> MapCameraPosition {
        guard !locations.isEmpty else {
            return .camera(
                MapCamera(
                    centerCoordinate: MapLocation.pond.coordinate,
                    distance: 1700,
                    heading: 0,
                    pitch: 80
                )
            )
        }
        let count = Double(locations.count)
        let centerLat = locations.reduce(0.0) { $0 + $1.latitude } / count
        let centerLng = locations.reduce(0.0) { $0 + $1.longitude } / count
        return .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
                distance: 1000,
                heading: 0,
                pitch: 45
            )
        )
    }
}

#Preview {
    Form {
        Section {
            SNUMapView(locations: [.pond])
                .frame(height: 301)
        }
    }
}
