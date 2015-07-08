//
//  CourseCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class CourseCellCollectionViewCell: UICollectionViewCell, UIAlertViewDelegate{

    @IBOutlet weak var courseText: UILabel!
    var singleClass : STSingleClass?
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 6
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longClick:"))
        self.addGestureRecognizer(longPress)
        
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 1) {
            TimeTableCollectionViewController.datasource.deleteLecture(singleClass!.lecture!)
        }
    }
    func longClick(gesture : UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            var alertView = UIAlertView(title: "SNUTT", message: "Do you want to Delete \(singleClass!.lecture!.name)?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            alertView.show()
        }
    }
    func setSingleClass(tmp : STSingleClass) {
        singleClass = tmp
        courseText.text = "\(tmp.lecture!.name)\n\(tmp.place)"
    }
}
