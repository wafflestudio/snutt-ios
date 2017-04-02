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

    var colorList = STColorManager.sharedInstance.colorList.colorList
    var nameList = STColorManager.sharedInstance.colorList.nameList

    init(initialColor : STColor, doneBlock: ((STColor) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((STColor)->Void)?) {
        self.doneBlock = doneBlock
        self.cancelBlock = cancelBlock
        self.selectedBlock = selectedBlock
        self.initialColor = initialColor
        super.init()
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0:
            let attribute = [NSForegroundColorAttributeName: colorList[row].fgColor.lighten(byPercentage: 0.4)]
            return NSAttributedString(string: nameList[row], attributes: attribute)
        default: return nil
        }
    }

    func onePixelImageWithColor(_ color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIImage(cgImage: context.makeImage()!)
        return image
    }

    func actionSheetPicker(_ actionSheetPicker: AbstractActionSheetPicker!, configurePickerView pickerView: UIPickerView!) {
        pickerView.tintColor = UIColor.white
        let bgImageColor = UIColor.black.withAlphaComponent(0.2)
        actionSheetPicker.toolbar.setBackgroundImage(onePixelImageWithColor(bgImageColor),
                                                     forToolbarPosition: UIBarPosition.bottom,
                                                     barMetrics: UIBarMetrics.default)
        actionSheetPicker.toolbar.tintColor = UIColor.white
        actionSheetPicker.toolbar.barTintColor = UIColor.white
        
        guard let index = colorList.index(of: initialColor) else {
            pickerView.selectRow(0, inComponent: 0, animated: false)
            selectedBlock?(colorList[0])
            return
        }
        pickerView.selectRow(index, inComponent: 0, animated: false)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return nameList.count
        default: return 0
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedBlock?(colorList[row])
    }

    func actionSheetPickerDidSucceed(_ actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        let pickerView = actionSheetPicker.pickerView as! UIPickerView
        let index = pickerView.selectedRow(inComponent: 0)
        doneBlock?(colorList[index])
    }

    func actionSheetPickerDidCancel(_ actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        cancelBlock?()
    }

    internal static func showWithColor(_ color: STColor, doneBlock: ((STColor) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((STColor)->Void)?, origin : AnyObject! ) {
        let colorPickerDelegate = STColorActionSheetPicker(initialColor: color, doneBlock: doneBlock, cancelBlock: cancelBlock, selectedBlock: selectedBlock)
        let actionSheetPicker = ActionSheetCustomPicker()
        
        let overlayBlack = UIColor.black.withAlphaComponent(0.3)
        actionSheetPicker.pickerBackgroundColor = overlayBlack
        actionSheetPicker.delegate = colorPickerDelegate
        actionSheetPicker.hideCancel = false
        
        actionSheetPicker.tapDismissAction = TapAction.cancel
        
        actionSheetPicker.show()
    }
}
