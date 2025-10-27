//
//  LectureMapView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import MapKit
import SharedUIComponents
import SharedUIMapKit
import SwiftUI
import TimetableInterface
import TimetableUIComponents
import UIKit

struct LectureMapView: View {
    let buildings: [Building]
    let showMismatchWarning: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SNUMapView(
                locations: buildingsToLocations(),
                onLocationTap: openExternalMap
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxWidth: .infinity)
            .frame(height: 256)
            .padding(.top, 10)

            if showMismatchWarning {
                Text(TimetableStrings.editMapLocationWarning)
                    .font(.system(size: 13))
                    .foregroundStyle(
                        colorScheme == .dark
                            ? SharedUIComponentsAsset.gray30.swiftUIColor.opacity(0.6)
                            : SharedUIComponentsAsset.darkGray.swiftUIColor.opacity(0.6)
                    )
                    .padding(.bottom, 2)
                    .padding(.top, 6)
            }
        }
    }

    private func buildingsToLocations() -> [MapLocation] {
        buildings.map { building in
            MapLocation(
                latitude: building.locationInDMS.latitude,
                longitude: building.locationInDMS.longitude,
                label: building.number + TimetableStrings.editMapBuildingSuffix
            )
        }
    }

    private func openExternalMap(location: MapLocation) {
        let coord = location.coordinate

        // 1순위: 네이버맵
        if let naverURL = makeNaverMapURL(coordinate: coord, label: location.label),
            UIApplication.shared.canOpenURL(naverURL)
        {
            UIApplication.shared.open(naverURL)
            return
        }

        // 2순위: 카카오맵
        if let kakaoURL = makeKakaoMapURL(coordinate: coord),
            UIApplication.shared.canOpenURL(kakaoURL)
        {
            UIApplication.shared.open(kakaoURL)
            return
        }

        // 3순위: Apple Maps (항상 사용 가능)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord))
        mapItem.name = location.label
        mapItem.openInMaps(launchOptions: nil)
    }

    private func makeNaverMapURL(coordinate: CLLocationCoordinate2D, label: String) -> URL? {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let urlString =
            "nmap://place?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&name=\(label)&appname=\(bundleID)"
        return urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap { URL(string: $0) }
    }

    private func makeKakaoMapURL(coordinate: CLLocationCoordinate2D) -> URL? {
        URL(string: "kakaomap://look?p=\(coordinate.latitude),\(coordinate.longitude)")
    }
}
