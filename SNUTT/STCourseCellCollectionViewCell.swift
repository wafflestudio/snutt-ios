//
//  STCourseCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STCourseCellCollectionViewCell: UICollectionViewCell, UIAlertViewDelegate{
    
    @IBOutlet weak var courseText: UILabel!
    var singleClass : STSingleClass! {
        didSet {
            setText()
        }
    }
    
    var lecture : STLecture! {
        didSet {
            setText()
            setColor()
        }
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
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
    
    func setText() {
        var text = ""
        if let lecture = self.lecture {
            text = lecture.title
        }
        if let singleClass = self.singleClass {
            if text == "" {
                text = singleClass.place
            } else {
                text = text + "\n" + singleClass.place
            }
        }
        courseText.text = text
    }
    
    func setColor() {
        self.backgroundColor = lecture.color.bgColor
        courseText.textColor = lecture.color.fgColor
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        /* //DEBUG
        if(buttonIndex == 1) {
            STCourseBooksManager.sharedInstance.currentCourseBook?.deleteLecture(singleClass!.lecture!)
        }
        */
    }
    func longClick(gesture : UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            let alertView = UIAlertView(title: "SNUTT", message: "Do you want to Delete \(lecture!.title)?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            alertView.show()
        }
    }
}
