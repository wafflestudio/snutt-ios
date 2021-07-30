//
//  STColorManager.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 18..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

class STColorManager {
    
    // MARK: Singleton
    
    fileprivate static var sharedManager : STColorManager? = nil
    static var sharedInstance : STColorManager{
        get {
            if sharedManager == nil {
                sharedManager = STColorManager()
            }
            return sharedManager!
        }
    }
    
    fileprivate init() {
        self.loadData()
        #if TODAY_EXTENSION
        #else
        self.updateData()
        #endif
    }
    
    var colorList: STColorList!
    
    func loadData() {
        colorList = STDefaults[.colorList] ?? STColorList(colorList: [], nameList: [])
    }
    
    func saveData() {
        STDefaults[.colorList] = colorList
    }
    
}

struct ColorListInTheme {
    static let SNUTT = ["#E54459", "#F58D3D", "#FAC42D", "#A6D930", "#2BC267","#1BD0C8", "#1D99E8", "#4F48C4", "#AF56B3"]
    static let FALL = ["#B82E31", "#DB701C", "#EAA32A", "#C6C013", "#3A856E", "#19B2AC", "#3994CE", "#3F3A9C", "#924396"]
    static let MODERN = ["#F0652A", "#F5AD3E", "#F4EFBE", "#89C291", "#266F55", "#13808F", "#366689", "#432920", "#D82F3D"]
    static let CHERRY_BLOSSOM = ["#FD79A8", "#FEC9DD", "#FEB0CC", "#FE93BF", "#E9B1D0", "#FFE4F4", "#BB8EA7", "#BDB4BF", "#E16597"]
    static let ICE = ["#AABDCF", "#C0E9E8", "#66B6CA", "#015F95", "#A8D0DB", "#CBE9FE", "#62A9D1", "#20363D", "#6D8A96"]
    static let LAWN = ["#4FBEAA", "#9FC1A4", "#5A8173", "#84AEB1", "#266F55", "#D0E0C4", "#59886D", "#476060", "#3D7068"]
}

enum STTheme: Int, CaseIterable {
    case SNUTT = 0
    case FALL = 1
    case MODERN = 2
    case CHERRY_BLOSSOM = 3
    case ICE = 4
    case LAWN = 5
    
    func getColorList() -> [String] {
        switch self {
        case .SNUTT:
            return ColorListInTheme.SNUTT
        case .FALL:
            return ColorListInTheme.FALL
        case .MODERN:
            return ColorListInTheme.MODERN
        case .CHERRY_BLOSSOM:
            return ColorListInTheme.CHERRY_BLOSSOM
        case .ICE:
            return ColorListInTheme.ICE
        case .LAWN:
            return ColorListInTheme.LAWN
        }
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
