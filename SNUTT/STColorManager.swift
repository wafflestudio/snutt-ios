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
