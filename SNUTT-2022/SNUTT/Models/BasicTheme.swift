//
//  Theme.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/11.
//

enum BasicTheme: Int, CaseIterable {
    case snutt = 0
    case fall = 1
    case modern = 2
    case cherryBlossom = 3
    case ice = 4
    case lawn = 5

    private func getColorList() -> [String] {
        switch self {
        case .snutt:
            return ["#ffffff", "#E54459", "#F58D3D", "#FAC42D", "#A6D930", "#2BC267", "#1BD0C8", "#1D99E8", "#4F48C4", "#AF56B3"]
        case .fall:
            return ["#ffffff", "#B82E31", "#DB701C", "#EAA32A", "#C6C013", "#3A856E", "#19B2AC", "#3994CE", "#3F3A9C", "#924396"]
        case .modern:
            return ["#ffffff", "#F0652A", "#F5AD3E", "#998F36", "#89C291", "#266F55", "#13808F", "#366689", "#432920", "#D82F3D"]
        case .cherryBlossom:
            return ["#ffffff", "#FD79A8", "#FEC9DD", "#FEB0CC", "#FE93BF", "#E9B1D0", "#C67D97", "#BB8EA7", "#BDB4BF", "#E16597"]
        case .ice:
            return ["#ffffff", "#AABDCF", "#C0E9E8", "#66B6CA", "#015F95", "#A8D0DB", "#66B6CA", "#62A9D1", "#20363D", "#6D8A96"]
        case .lawn:
            return ["#ffffff", "#4FBEAA", "#9FC1A4", "#5A8173", "#84AEB1", "#266F55", "#D0E0C4", "#59886D", "#476060", "#3D7068"]
        }
    }

    func getLectureColorList() -> [LectureColor] {
        getColorList().map { .init(fg: .white, bg: .init(hex: $0)) }
    }

    func getColor(at colorIndex: Int) -> LectureColor {
        return getLectureColorList()[colorIndex]
    }

    var imageName: String {
        switch self {
        case .snutt:
            return "theme.snutt"
        case .fall:
            return "theme.fall"
        case .modern:
            return "theme.modern"
        case .cherryBlossom:
            return "theme.cherryblossom"
        case .ice:
            return "theme.ice"
        case .lawn:
            return "theme.lawn"
        }
    }

    var name: String {
        switch self {
        case .snutt:
            return "SNUTT"
        case .fall:
            return "가을"
        case .modern:
            return "모던"
        case .cherryBlossom:
            return "벚꽃"
        case .ice:
            return "얼음"
        case .lawn:
            return "잔디"
        }
    }
}
