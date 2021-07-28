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
}

enum STTheme: Int {
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
            
        default:
            return ColorListInTheme.SNUTT
        }
    }
}

typealias ThemeColor = String

