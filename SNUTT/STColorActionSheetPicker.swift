//
//  STColorActionSheetPicker.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 14..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation
import Foundation
import ActionSheetPicker_3_0

class STColorActionSheetPicker : NSObject, ActionSheetCustomPickerDelegate {
    
    var doneBlock : ((STColor) -> Void)?
    var cancelBlock : (() -> Void)?
    var selectedBlock: ((STColor)->Void)?
    var initialColor : STColor
    
    init(initialColor : STColor, doneBlock: ((STColor) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((STColor)->Void)?) {
        self.doneBlock = doneBlock
        self.cancelBlock = cancelBlock
        self.selectedBlock = selectedBlock
        self.initialColor = initialColor
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0:
            let attribute = [NSForegroundColorAttributeName: STColor.colorList[row].fgColor.lightenByPercentage(0.4)]
            return NSAttributedString(string: STColor.colorNameList[row], attributes: attribute)
        default: return nil
        }
    }

    func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.PremultipliedLast
        let context = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, bitmapInfo.rawValue)!
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        return image
    }

    func actionSheetPicker(actionSheetPicker: AbstractActionSheetPicker!, configurePickerView pickerView: UIPickerView!) {
        pickerView.tintColor = UIColor.whiteColor()
        let bgImageColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        actionSheetPicker.toolbar.setBackgroundImage(onePixelImageWithColor(bgImageColor),
                                                     forToolbarPosition: UIBarPosition.Bottom,
                                                     barMetrics: UIBarMetrics.Default)
        actionSheetPicker.toolbar.tintColor = UIColor.whiteColor()
        actionSheetPicker.toolbar.barTintColor = UIColor.whiteColor()
        
        guard let index = STColor.colorList.indexOf(initialColor) else {
            pickerView.selectRow(0, inComponent: 0, animated: false)
            selectedBlock?(STColor.colorList[0])
            return
        }
        pickerView.selectRow(index, inComponent: 0, animated: false)
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return STColor.colorNameList.count
        default: return 0
        }
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedBlock?(STColor.colorList[row])
    }

    func actionSheetPickerDidSucceed(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        let pickerView = actionSheetPicker.pickerView as! UIPickerView
        let index = pickerView.selectedRowInComponent(0)
        doneBlock?(STColor.colorList[index])
    }

    func actionSheetPickerDidCancel(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        cancelBlock?()
    }

    internal static func showWithColor(color: STColor, doneBlock: ((STColor) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((STColor)->Void)?, origin : AnyObject! ) {
        let colorPickerDelegate = STColorActionSheetPicker(initialColor: color, doneBlock: doneBlock, cancelBlock: cancelBlock, selectedBlock: selectedBlock)
        let actionSheetPicker = ActionSheetCustomPicker()
        
        let overlayBlack = UIColor.blackColor().colorWithAlphaComponent(0.3)
        actionSheetPicker.pickerBackgroundColor = overlayBlack
        actionSheetPicker.delegate = colorPickerDelegate
        actionSheetPicker.hideCancel = false
        
        actionSheetPicker.tapDismissAction = TapAction.Cancel
        
        actionSheetPicker.showActionSheetPicker()
    }
}
