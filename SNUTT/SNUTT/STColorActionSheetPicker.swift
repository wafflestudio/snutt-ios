//
//  STColorActionSheetPicker.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 14..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import ActionSheetPicker_3_0
import Foundation

class STColorActionSheetPicker: NSObject, ActionSheetCustomPickerDelegate {
    var doneBlock: ((Int) -> Void)?
    var cancelBlock: (() -> Void)?
    var selectedBlock: ((Int) -> Void)?
    var initialColorIndex: Int

    var colorList = STColorManager.sharedInstance.colorList.colorList
    var nameList = STColorManager.sharedInstance.colorList.nameList

    init(initialColorIndex: Int, doneBlock: ((Int) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((Int) -> Void)?) {
        self.doneBlock = doneBlock
        self.cancelBlock = cancelBlock
        self.selectedBlock = selectedBlock
        self.initialColorIndex = initialColorIndex
        super.init()
    }

    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0:
            let attribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): colorList[row].bgColor.lighten(byPercentage: 0.4)]
            return NSAttributedString(string: nameList[row], attributes: convertToOptionalNSAttributedStringKeyDictionary(attribute))
        default: return nil
        }
    }

    func onePixelImageWithColor(_ color: UIColor) -> UIImage {
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

        if initialColorIndex == 0 {
            pickerView.selectRow(0, inComponent: 0, animated: false)
            selectedBlock?(1)
        } else {
            pickerView.selectRow(initialColorIndex - 1, inComponent: 0, animated: false)
        }
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return nameList.count
        default: return 0
        }
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedBlock?(row + 1)
    }

    func actionSheetPickerDidSucceed(_ actionSheetPicker: AbstractActionSheetPicker!, origin _: AnyObject!) {
        let pickerView = actionSheetPicker.pickerView as! UIPickerView
        let index = pickerView.selectedRow(inComponent: 0)
        doneBlock?(index + 1)
    }

    func actionSheetPickerDidCancel(_: AbstractActionSheetPicker!, origin _: AnyObject!) {
        cancelBlock?()
    }

    internal static func showWithColor(_ colorIndex: Int, doneBlock: ((Int) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((Int) -> Void)?, origin _: AnyObject!) {
        let colorPickerDelegate = STColorActionSheetPicker(initialColorIndex: colorIndex, doneBlock: doneBlock, cancelBlock: cancelBlock, selectedBlock: selectedBlock)
        let actionSheetPicker = ActionSheetCustomPicker()

        let overlayBlack = UIColor.black.withAlphaComponent(0.3)
        actionSheetPicker.pickerBackgroundColor = overlayBlack
        actionSheetPicker.delegate = colorPickerDelegate
        actionSheetPicker.hideCancel = false

        actionSheetPicker.tapDismissAction = TapAction.cancel

        actionSheetPicker.show()
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}
