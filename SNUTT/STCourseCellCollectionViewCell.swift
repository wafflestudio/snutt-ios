//
//  STCourseCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

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
    
    var longClicked: ((STCourseCellCollectionViewCell)->())?
    var tapped: ((STCourseCellCollectionViewCell)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 6
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longClick))
        self.addGestureRecognizer(longPress)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tap)
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
        courseText.text = text.breakOnlyAtNewLineAndSpace
        courseText.baselineAdjustment = .alignCenters
    }
    
    func setColor() {
        let color = lecture.getColor()
        self.backgroundColor = color.bgColor
        courseText.textColor = color.fgColor
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        /* //DEBUG
        if(buttonIndex == 1) {
            STCourseBooksManager.sharedInstance.currentCourseBook?.deleteLecture(singleClass!.lecture!)
        }
        */
    }
    func longClick(_ gesture : UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            longClicked?(self)
        }
    }
    func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.recognized {
            tapped?(self)
        }
    }
}
