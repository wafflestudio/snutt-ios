//
//  Theme.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/11.
//

enum Theme: Int, CaseIterable {
    case SNUTT = 0
    case FALL = 1
    case MODERN = 2
    case CHERRY_BLOSSOM = 3
    case ICE = 4
    case LAWN = 5

    func getColorList() -> [String] {
        switch self {
        case .SNUTT:
            return ["#ffffff", "#E54459", "#F58D3D", "#FAC42D", "#A6D930", "#2BC267", "#1BD0C8", "#1D99E8", "#4F48C4", "#AF56B3"]
        case .FALL:
            return ["#ffffff", "#B82E31", "#DB701C", "#EAA32A", "#C6C013", "#3A856E", "#19B2AC", "#3994CE", "#3F3A9C", "#924396"]
        case .MODERN:
            return ["#ffffff", "#F0652A", "#F5AD3E", "#998F36", "#89C291", "#266F55", "#13808F", "#366689", "#432920", "#D82F3D"]
        case .CHERRY_BLOSSOM:
            return ["#ffffff", "#FD79A8", "#FEC9DD", "#FEB0CC", "#FE93BF", "#E9B1D0", "#C67D97", "#BB8EA7", "#BDB4BF", "#E16597"]
        case .ICE:
            return ["#ffffff", "#AABDCF", "#C0E9E8", "#66B6CA", "#015F95", "#A8D0DB", "#66B6CA", "#62A9D1", "#20363D", "#6D8A96"]
        case .LAWN:
            return ["#ffffff", "#4FBEAA", "#9FC1A4", "#5A8173", "#84AEB1", "#266F55", "#D0E0C4", "#59886D", "#476060", "#3D7068"]
        }
    }
    
    func getColor(at colorIndex: Int) -> String {
        return getColorList()[colorIndex]
    }

    func getImageName() -> String {
        switch self {
        case .SNUTT:
            return "SNUTTTheme"
        case .FALL:
            return "FallTheme"
        case .MODERN:
            return "ModernTheme"
        case .CHERRY_BLOSSOM:
            return "CherryBlossomTheme"
        case .ICE:
            return "IceTheme"
        case .LAWN:
            return "LawnTheme"
        }
    }

    func getName() -> String {
        switch self {
        case .SNUTT:
            return "SNUTT"
        case .FALL:
            return "가을"
        case .MODERN:
            return "모던"
        case .CHERRY_BLOSSOM:
            return "벚꽃"
        case .ICE:
            return "얼음"
        case .LAWN:
            return "잔디"
        }
    }
}
