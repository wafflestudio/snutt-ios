//
//  STCourseCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

func STColorFromHex (hex:String) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substringFromIndex(1)
    }
    
    if (count(cString) != 6) {
        return UIColor.grayColor()
    }
    
    let rString = (cString as NSString).substringToIndex(2)
    let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
    let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    NSScanner(string: rString).scanHexInt(&r)
    NSScanner(string: gString).scanHexInt(&g)
    NSScanner(string: bString).scanHexInt(&b)
    
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}

class STCourseCellCollectionViewCell: UICollectionViewCell, UIAlertViewDelegate{
    
    static var backgroundColorList : [UIColor] =
    [STColorFromHex("#B6F9B2"), STColorFromHex("#BFF7F8"), STColorFromHex("#94E6FE"), STColorFromHex("#F6B5F5"), STColorFromHex("#FFF49A"), STColorFromHex("#FFB2BC")]
    static var labelColorList : [UIColor] =
    [STColorFromHex("#2B8728"), STColorFromHex("#45B2B8"), STColorFromHex("#1579C2"), STColorFromHex("#A337A1"), STColorFromHex("#B8991B"), STColorFromHex("#BA313B")]
    
    
    
    @IBOutlet weak var courseText: UILabel!
    var singleClass : STSingleClass? {
        didSet {
            courseText.text = "\(singleClass!.lecture!.name)\n\(singleClass!.place)"
            setColor()
        }
    }
    
   
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 6
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longClick:"))
        self.addGestureRecognizer(longPress)
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: Selector("swipeToLeft:"))
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: Selector("swipeToRight:"))
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right
        self.addGestureRecognizer(swipeRightGesture)
    }
    func setColor() {
        self.backgroundColor = STCourseCellCollectionViewCell.backgroundColorList[singleClass!.lecture!.colorIndex]
        courseText.textColor = STCourseCellCollectionViewCell.labelColorList[singleClass!.lecture!.colorIndex]
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 1) {
            STCourseBooksManager.sharedInstance.currentCourseBook?.deleteLecture(singleClass!.lecture!)
        }
    }
    func longClick(gesture : UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            var alertView = UIAlertView(title: "SNUTT", message: "Do you want to Delete \(singleClass!.lecture!.name)?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            alertView.show()
        }
    }
    func swipeToLeft(gesture : UISwipeGestureRecognizer) {
        var colorIndex = singleClass!.lecture!.colorIndex
        if colorIndex == 0 {
            colorIndex = STCourseCellCollectionViewCell.backgroundColorList.count-1
        } else {
            colorIndex--
        }
        singleClass!.lecture!.colorIndex = colorIndex
        STCourseBooksManager.sharedInstance.saveData()
        STCourseBooksManager.sharedInstance.reloadTimeTable()
    }
    func swipeToRight(gesture : UISwipeGestureRecognizer) {
        var colorIndex = singleClass!.lecture!.colorIndex
        if colorIndex == STCourseCellCollectionViewCell.backgroundColorList.count-1 {
            colorIndex = 0
        } else {
            colorIndex++
        }
        singleClass!.lecture!.colorIndex = colorIndex
        STCourseBooksManager.sharedInstance.saveData()
        STCourseBooksManager.sharedInstance.reloadTimeTable()
    }
}
