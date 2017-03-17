//
//  STColorManager.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 18..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

class STColorManager {

    // MARK: Singleton

    private static var sharedManager : STColorManager? = nil
    static var sharedInstance : STColorManager{
        get {
            if sharedManager == nil {
                sharedManager = STColorManager()
            }
            return sharedManager!
        }
    }

    private init() {
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

    func updateData() {
        STNetworking.getColors({colorList, nameList in
            self.colorList = STColorList(colorList: colorList, nameList: nameList)
            self.saveData()
            STEventCenter.sharedInstance.postNotification(event: STEvent.ColorListUpdated, object: nil)
            }, failure: nil)
    }
    
}
