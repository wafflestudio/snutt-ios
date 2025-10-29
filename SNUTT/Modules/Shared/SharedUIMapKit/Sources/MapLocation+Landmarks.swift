//
//  Landmark.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import MapKit

extension MapLocation {
    public static let predefinedLandmarks: [MapLocation] = [
        .pond,
        MapLocation(latitude: 37.45928, longitude: 126.95058, label: "학생회관"),
        MapLocation(latitude: 37.46564, longitude: 126.95190, label: "경영대학"),
        MapLocation(latitude: 37.46471, longitude: 126.94994, label: "종합운동장"),
        MapLocation(latitude: 37.46331, longitude: 126.95101, label: "사회과학대학"),
        MapLocation(latitude: 37.46233, longitude: 126.95172, label: "법학전문대학원"),
        MapLocation(latitude: 37.45926, longitude: 126.95210, label: "중앙도서관"),
        MapLocation(latitude: 37.45769, longitude: 126.94858, label: "농업생명과학대학"),
        MapLocation(latitude: 37.45483, longitude: 126.95062, label: "글로벌공학교육센터"),
        MapLocation(latitude: 37.44874, longitude: 126.95256, label: "제2공학관"),
        MapLocation(latitude: 37.44985, longitude: 126.95248, label: "제1공학관"),
        MapLocation(latitude: 37.45775, longitude: 126.95023, label: "자연과학대학"),
        MapLocation(latitude: 37.46017, longitude: 126.95481, label: "사범대학"),
        MapLocation(latitude: 37.46046, longitude: 126.95412, label: "인문관"),
        MapLocation(latitude: 37.46061, longitude: 126.95064, label: "잔디광장"),
        MapLocation(latitude: 37.45999, longitude: 126.95127, label: "행정관"),
        MapLocation(latitude: 37.46146, longitude: 126.95118, label: "문화관"),
        MapLocation(latitude: 37.46644, longitude: 126.94972, label: "미술관"),
        MapLocation(latitude: 37.46447, longitude: 126.95221, label: "박물관"),
        MapLocation(latitude: 37.46754, longitude: 126.95220, label: "체육관"),
        MapLocation(latitude: 37.46822, longitude: 126.95161, label: "포스코"),
        MapLocation(latitude: 37.46336, longitude: 126.95883, label: "관악사"),
        MapLocation(latitude: 37.45820, longitude: 126.95288, label: "약학대학"),
        MapLocation(latitude: 37.46313, longitude: 126.95351, label: "음악대학"),
        MapLocation(latitude: 37.46352, longitude: 126.95324, label: "미술대학"),
        MapLocation(latitude: 37.46433, longitude: 126.95470, label: "국제대학원"),
    ]

    public static let pond = MapLocation(latitude: 37.46073, longitude: 126.95208, label: "자하연")
}
