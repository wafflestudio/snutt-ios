//
//  STColorManager.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 18..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

class STColorManager {

    init() {
        self.loadData()
        self.updateData()
    }

    var colorList: STColorList!

    func loadData() {
        colorList = STDefaults[.colorList] ?? STColorList(colorList: [], nameList: [])
    }

    func saveData() {
        STDefaults[.colorList] = colorList
    }
    
}
