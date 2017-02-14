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
        actionSheetPicker.toolbar.tintColor = UIColor.blackColor()
        
        let dayIndex = dayRow.indexOf(initialTime.day)!
        let startPeriodIndex = startPeriodRow.indexOf(initialTime.startPeriod)!
        setEndPeriodRowWithStartPeriod(initialTime.startPeriod)
        let endPeriodIndex = endPeriodRow.indexOf(initialTime.endPeriod)!
        pickerView.selectRow(dayIndex, inComponent: 0, animated: false)
        pickerView.selectRow(startPeriodIndex, inComponent: 1, animated: false)
        pickerView.selectRow(endPeriodIndex, inComponent: 2, animated: false)
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
        if component == 1 {
            let pastEndPeriod = endPeriodRow[pickerView.selectedRowInComponent(2)]
            self.setEndPeriodRowWithStartPeriod(STPeriod.allValues[row])
            pickerView.reloadComponent(2)
            if endPeriodRow.last! <= pastEndPeriod {
                pickerView.selectRow(endPeriodRow.count, inComponent: 2, animated: false)
            } else if endPeriodRow.first! >= pastEndPeriod {
                pickerView.selectRow(0, inComponent: 2, animated: false)
            } else {
                let index = endPeriodRow.indexOf(pastEndPeriod)!
                pickerView.selectRow(index, inComponent: 2, animated: false)
            }
        }
    }
    
    func actionSheetPickerDidSucceed(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        let pickerView = actionSheetPicker.pickerView as! UIPickerView
        let day = dayRow[pickerView.selectedRowInComponent(0)]
        let startPeriod = startPeriodRow[pickerView.selectedRowInComponent(1)]
        let endPeriod = endPeriodRow[pickerView.selectedRowInComponent(2)]
        let selectedTime = STTime(day: day.rawValue, startPeriod: startPeriod, duration: endPeriod - startPeriod)
        doneBlock?(selectedTime)
    }
    
    func actionSheetPickerDidCancel(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        cancelBlock?()
    }
    
    internal static func showWithTime(time: STTime, doneBlock: ((STTime) -> Void)?, cancelBlock: (() -> Void)?, origin : AnyObject! ) {
        let timePickerDelegate = STTimeActionSheetPicker(initialTime: time, doneBlock: doneBlock, cancelBlock: cancelBlock)
        let title = "시간"
        ActionSheetCustomPicker.showPickerWithTitle(title, delegate: timePickerDelegate, showCancelButton: true, origin: origin)
    }
    
}
