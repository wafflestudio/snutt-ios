//
//  Theme+BuiltIn.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

extension Theme {
    public static let snutt: Theme = makeTheme(
        name: "snutt",
        hexColors: ["#E54459", "#F58D3D", "#FAC42D", "#A6D930", "#2BC267", "#1BD0C8", "#1D99E8", "#4F48C4", "#AF56B3"]
    )
    public static let fall: Theme = makeTheme(
        name: "fall",
        hexColors: ["#B82E31", "#DB701C", "#EAA32A", "#C6C013", "#3A856E", "#19B2AC", "#3994CE", "#3F3A9C", "#924396"]
    )
    public static let modern: Theme = makeTheme(
        name: "modern",
        hexColors: ["#F0652A", "#F5AD3E", "#998F36", "#89C291", "#266F55", "#13808F", "#366689", "#432920", "#D82F3D"]
    )
    public static let cherryBlossom: Theme = makeTheme(
        name: "cherryBlossom",
        hexColors: ["#FD79A8", "#FEC9DD", "#FEB0CC", "#FE93BF", "#E9B1D0", "#C67D97", "#BB8EA7", "#BDB4BF", "#E16597"]
    )
    public static let ice: Theme = makeTheme(
        name: "ice",
        hexColors: ["#AABDCF", "#C0E9E8", "#66B6CA", "#015F95", "#A8D0DB", "#66B6CA", "#62A9D1", "#20363D", "#6D8A96"]
    )
    public static let lawn: Theme = makeTheme(
        name: "lawn",
        hexColors: ["#4FBEAA", "#9FC1A4", "#5A8173", "#84AEB1", "#266F55", "#D0E0C4", "#59886D", "#476060", "#3D7068"]
    )
}

extension Theme {

    // Custom Themes for Preview

    public static let preview1: Theme = makeTheme(
        name: "preview1",
        hexColors: ["#FFADAD", "#FFD6A5", "#FDFFB6", "#CAFFBF", "#9BF6FF", "#A0C4FF", "#BDB2FF", "#FFC6FF", "#FFFFFC"],
        isCustom: true
    )

    public static let preview2: Theme = makeTheme(
        name: "preview2",
        hexColors: ["#264653", "#2A9D8F", "#E9C46A", "#F4A261", "#E76F51", "#F7B267", "#70C1B3", "#FFD6BA", "#D4A5A5"],
        isCustom: true
    )

    public static let preview3: Theme = makeTheme(
        name: "preview3",
        hexColors: ["#6A0572", "#AB83A1", "#C3B1E1", "#F1D4D4", "#F7E1D7", "#F9F5F6", "#C9BBCF", "#A1B5D8", "#9AD0EC"],
        isCustom: true
    )
}

extension Theme {
    private static func makeTheme(name: String, hexColors: [String], isCustom: Bool = false) -> Theme {
        .init(
            id: name,
            name: name,
            colors: hexColors.map { .init(fgHex: "#ffffff", bgHex: $0) },
            isCustom: isCustom
        )
    }
}
