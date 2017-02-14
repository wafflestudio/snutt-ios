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
    
    var controller : STTimetableCollectionViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //layer.cornerRadius = 6
        
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
        courseText.baselineAdjustment = .AlignCenters
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
            let oldColor = self.lecture.color
            guard let collectionView = controller.collectionView else {
                return
            }
            guard let indexPath = controller.collectionView?.indexPathForCell(self) else {
                return
            }
            let num = collectionView.numberOfItemsInSection(indexPath.section)
            let cellList = (0..<num).map { i in collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: indexPath.section)) as! STCourseCellCollectionViewCell}
            STColorActionSheetPicker.showWithColor(lecture.color, doneBlock: { selectedColor in
                var newLecture = self.lecture
                newLecture.color = selectedColor
                var oldLecture = self.lecture
                oldLecture.color = oldColor
                STTimetableManager.sharedInstance.updateLecture(oldLecture, newLecture: newLecture, failure: {
                    cellList.forEach { cell in
                        cell.lecture.color = oldColor
                    }
                })
                }, cancelBlock: {
                    cellList.forEach { cell in
                        cell.lecture.color = oldColor
                    }
                }, selectedBlock: { color in
                    cellList.forEach { cell in
                        cell.lecture.color = color
                    }
                }, origin: self)
        }
    }
    func tap(gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Recognized {
            let detailController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LectureDetailTableViewController") as! STLectureDetailTableViewController
            detailController.lecture = self.lecture
            self.controller.navigationController?.pushViewController(detailController, animated: true)
        }
    }
}
