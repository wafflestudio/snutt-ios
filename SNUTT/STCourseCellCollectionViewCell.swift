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
        var margin : CGFloat = 4.0;
        if isLargerThanSE() {
            margin = 5.0;
        }
        self.layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longClick))
        self.addGestureRecognizer(longPress)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tap)

        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.05).cgColor
    }
    
    func setText() {
        var text = NSMutableAttributedString()
        if let lecture = self.lecture {
            let font = UIFont.systemFont(ofSize: 10.0)
            text.append(NSAttributedString(string: lecture.titleBreakLine, attributes: [NSFontAttributeName: font]))
        }
        if let singleClass = self.singleClass {
            let placeText = singleClass.place
            var size : CGFloat = 11.0
            if isLargerThanSE() {
                if placeText.characters.count >= 8 {
                    size = 10.0
                } else {
                    size = 11.0
                }
            } else {
                if placeText.characters.count >= 8 {
                    size = 9.0
                } else {
                    size = 10.0
                }
            }
            let font = UIFont.boldSystemFont(ofSize: size)
            if text.length != 0 {
                text.append(NSAttributedString(string: "\n"))
            }
            text.append(NSAttributedString(string: singleClass.placeBreakLine, attributes: [NSFontAttributeName: font]))
        }
        courseText.attributedText = text
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
