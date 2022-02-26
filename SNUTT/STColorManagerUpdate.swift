//
//  STColorManagerUpdate.swift
//  SNUTT
//
//  Created by Rajin on 2017. 4. 9..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

extension STColorManager {
    func updateData() {
        STNetworking.getColors({ colorList, nameList in
            self.colorList = STColorList(colorList: colorList, nameList: nameList)
            self.saveData()
            STEventCenter.sharedInstance.postNotification(event: STEvent.ColorListUpdated, object: nil)
        }, failure: nil)
    }
}
