//
//  STTimeActionSheetPicker.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import ActionSheetPicker_3_0

class STTimeActionSheetPicker : NSObject, ActionSheetCustomPickerDelegate {
    
    let dayRow = STDay.allValues
    var startPeriodRow = STPeriod.allValues
    var endPeriodRow : [Double] = []
    
    var doneBlock : ((STTime) -> Void)?
    var cancelBlock : (() -> Void)?
    var initialTime : STTime
    var selectedIndex = [0,0,0]
    
    init(initialTime : STTime, doneBlock: ((STTime) -> Void)?, cancelBlock: (() -> Void)?) {
        self.doneBlock = doneBlock
        self.cancelBlock = cancelBlock
        self.initialTime = initialTime
    }
    
    func setEndPeriodRowWithStartPeriod(startPeriod : Double) {
        let periodValues = STPeriod.allValues + [Double(STPeriod.periodNum)]
        let startIndex = STPeriod.allValues.indexOf(startPeriod)! + 1
        endPeriodRow = Array(periodValues.suffixFrom(startIndex))
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return dayRow[row].longString()
        case 1: return startPeriodRow[row].periodString()
        case 2: return endPeriodRow[row].periodString()
        default: return ""
        }
    }
    
    func actionSheetPicker(actionSheetPicker: AbstractActionSheetPicker!, configurePickerView pickerView: UIPickerView!) {
        let dayIndex = dayRow.indexOf(initialTime.day)!
        let startPeriodIndex = startPeriodRow.indexOf(initialTime.startPeriod)!
        setEndPeriodRowWithStartPeriod(initialTime.startPeriod)
        let endPeriodIndex = endPeriodRow.indexOf(initialTime.endPeriod)!
        pickerView.selectRow(dayIndex, inComponent: 0, animated: false)
        pickerView.selectRow(startPeriodIndex, inComponent: 1, animated: false)
        pickerView.selectRow(endPeriodIndex, inComponent: 2, animated: false)
        selectedIndex = [dayIndex, startPeriodIndex, endPeriodIndex]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return dayRow.count
        case 1: return startPeriodRow.count
        case 2: return endPeriodRow.count
        default: return 0
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex[component] = row
        if component == 1 {
            self.setEndPeriodRowWithStartPeriod(STPeriod.allValues[row])
            pickerView.reloadComponent(2)
            selectedIndex[2] = 0
            pickerView.selectRow(0, inComponent: 2, animated: true)
        }
    }
    
    func actionSheetPickerDidSucceed(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        if let doneBlock = self.doneBlock {
            let day = dayRow[selectedIndex[0]]
            let startPeriod = startPeriodRow[selectedIndex[1]]
            let endPeriod = endPeriodRow[selectedIndex[2]]
            let selectedTime = STTime(day: day.rawValue, startPeriod: startPeriod, duration: endPeriod - startPeriod)
            doneBlock(selectedTime)
        }
    }
    
    func actionSheetPickerDidCancel(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        if let cancelBlock = self.cancelBlock {
            cancelBlock()
        }
    }
    
    internal static func showWithTime(time: STTime, doneBlock: ((STTime) -> Void)?, cancelBlock: (() -> Void)?, origin : AnyObject! ) {
        let timePickerDelegate = STTimeActionSheetPicker(initialTime: time, doneBlock: doneBlock, cancelBlock: cancelBlock)
        let title = NSLocalizedString("time_picker_title", comment: "")
        ActionSheetCustomPicker.showPickerWithTitle(title, delegate: timePickerDelegate, showCancelButton: true, origin: origin)
    }
    
}