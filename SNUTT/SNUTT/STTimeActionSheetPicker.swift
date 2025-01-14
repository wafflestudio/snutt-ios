//
//  STTimeActionSheetPicker.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import ActionSheetPicker_3_0
import Foundation

class STTimeActionSheetPicker: NSObject, ActionSheetCustomPickerDelegate {
    let dayRow = STDay.allValues
    var startPeriodRow = STPeriod.allValues
    var endPeriodRow: [Double] = []

    var doneBlock: ((STTime) -> Void)?
    var cancelBlock: (() -> Void)?
    var initialTime: STTime

    init(initialTime: STTime, doneBlock: ((STTime) -> Void)?, cancelBlock: (() -> Void)?) {
        self.doneBlock = doneBlock
        self.cancelBlock = cancelBlock
        self.initialTime = initialTime
    }

    func setEndPeriodRowWithStartPeriod(_ startPeriod: Double) {
        let periodValues = STPeriod.allValues + [Double(STPeriod.periodNum)]
        let startIndex = STPeriod.allValues.index(of: startPeriod)! + 1
        endPeriodRow = Array(periodValues.suffix(from: startIndex))
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return dayRow[row].longString()
        case 1: return startPeriodRow[row].periodString()
        case 2: return endPeriodRow[row].periodString()
        default: return ""
        }
    }

    func actionSheetPicker(_ actionSheetPicker: AbstractActionSheetPicker!, configurePickerView pickerView: UIPickerView!) {
        actionSheetPicker.toolbar.tintColor = UIColor.black

        let dayIndex = dayRow.index(of: initialTime.day)!
        let startPeriodIndex = startPeriodRow.index(of: initialTime.startPeriod) ?? 0
        setEndPeriodRowWithStartPeriod(initialTime.startPeriod)
        let endPeriodIndex = endPeriodRow.index(of: initialTime.endPeriod) ?? endPeriodRow.count - 1
        pickerView.selectRow(dayIndex, inComponent: 0, animated: false)
        pickerView.selectRow(startPeriodIndex, inComponent: 1, animated: false)
        pickerView.selectRow(endPeriodIndex, inComponent: 2, animated: false)
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return dayRow.count
        case 1: return startPeriodRow.count
        case 2: return endPeriodRow.count
        default: return 0
        }
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            let pastEndPeriod = endPeriodRow[pickerView.selectedRow(inComponent: 2)]
            setEndPeriodRowWithStartPeriod(STPeriod.allValues[row])
            pickerView.reloadComponent(2)
            if endPeriodRow.last! <= pastEndPeriod {
                pickerView.selectRow(endPeriodRow.count, inComponent: 2, animated: false)
            } else if endPeriodRow.first! >= pastEndPeriod {
                pickerView.selectRow(0, inComponent: 2, animated: false)
            } else {
                let index = endPeriodRow.index(of: pastEndPeriod)!
                pickerView.selectRow(index, inComponent: 2, animated: false)
            }
        }
    }

    func actionSheetPickerDidSucceed(_ actionSheetPicker: AbstractActionSheetPicker!, origin _: Any?) {
        let pickerView = actionSheetPicker.pickerView as! UIPickerView
        let day = dayRow[pickerView.selectedRow(inComponent: 0)]
        let startPeriod = startPeriodRow[pickerView.selectedRow(inComponent: 1)]
        var endPeriod = endPeriodRow[pickerView.selectedRow(inComponent: 2)]
        if startPeriod > endPeriod {
            endPeriod = startPeriod + 0.5
        }
        let selectedTime = STTime(day: day.rawValue, startPeriod: startPeriod, duration: endPeriod - startPeriod)
        doneBlock?(selectedTime)
    }

    func actionSheetPickerDidCancel(_: AbstractActionSheetPicker!, origin _: Any?) {
        cancelBlock?()
    }

    static func showWithTime(_ time: STTime, doneBlock: ((STTime) -> Void)?, cancelBlock: (() -> Void)?, origin: AnyObject!) {
        let timePickerDelegate = STTimeActionSheetPicker(initialTime: time, doneBlock: doneBlock, cancelBlock: cancelBlock)
        let title = "시간"
        ActionSheetCustomPicker.show(withTitle: title, delegate: timePickerDelegate, showCancelButton: true, origin: origin)
    }
}
