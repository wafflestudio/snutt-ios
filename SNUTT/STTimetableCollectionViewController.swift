//
//  STTimetableCollectionViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class STTimetableCollectionViewController: UICollectionViewController, UIAlertViewDelegate {
    
    var columnList = ["월", "화", "수", "목", "금", "토"]
    var rowList : [String] = []
    var showTemporary : Bool = false
    var timetable : STTimetable? = nil
    
    
    let LectureSectionOffset = 3
    let RatioForHeader : CGFloat = 0.67
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.registerNib(UINib(nibName: "STCourseCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseCell")
        self.collectionView?.registerNib(UINib(nibName: "STColumnHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColumnHeaderCell")
        self.collectionView?.registerNib(UINib(nibName: "STSlotCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SlotCell")
        
        for i in 0..<(STTime.periodNum) {
            rowList.append(Double(i).periodString())
        }
        let viewLayout = STTimetableLayout(aTimetable: timetable)
        self.collectionView?.collectionViewLayout = viewLayout
        (self.collectionView?.collectionViewLayout as! STTimetableLayout).timetableController = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.dataSource = TimetableCollectionViewController.datasource
        //TimetableCollectionViewController.datasource.collectionView = self.collectionView
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCellType(indexPath : NSIndexPath) -> STTimetableCellType {
        switch indexPath.section {
        case 0:
            return .Slot
        case 1:
            return .HeaderColumn
        case 2:
            return .HeaderRow
        case (timetable?.lectureList.count)! + LectureSectionOffset:
            return .TemporaryCourse
        default:
            return .Course
        }
    }
    
    func getSingleClass(indexPath : NSIndexPath) -> STSingleClass {
        let lectureIndex = indexPath.section - LectureSectionOffset
        let classIndex = indexPath.row
        if lectureIndex == timetable!.lectureList.count {
            return timetable!.temporaryLecture!.classList[classIndex]
        }
        return timetable!.lectureList[lectureIndex].classList[classIndex]
    }
    
    func getLecture(indexPath: NSIndexPath) -> STLecture {
        let lectureIndex = indexPath.section - LectureSectionOffset
        if lectureIndex == timetable!.lectureList.count {
            return timetable!.temporaryLecture!
        }
        return timetable!.lectureList[lectureIndex]
    }
    
    func reloadTimetable() {
        self.collectionView?.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return columnList.count
        case 2:
            return rowList.count
        default:
            let index = section - LectureSectionOffset
            if index < timetable!.lectureList.count {
                return timetable!.lectureList[index].classList.count
            } else if index == timetable!.lectureList.count && timetable!.temporaryLecture != nil {
                return timetable!.temporaryLecture!.classList.count
            } else {
                return 0
            }
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if showTemporary {
            return LectureSectionOffset + timetable!.lectureList.count + 1
        } else {
            return LectureSectionOffset + timetable!.lectureList.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch getCellType(indexPath) {
        case .HeaderColumn:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColumnHeaderCell", forIndexPath: indexPath) as! STColumnHeaderCollectionViewCell
            cell.contentLabel.text = columnList[indexPath.row]
            return cell
        case .HeaderRow:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColumnHeaderCell", forIndexPath: indexPath) as! STColumnHeaderCollectionViewCell
            cell.contentLabel.text = rowList[indexPath.row]
            return cell
        case .Slot:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SlotCell", forIndexPath: indexPath) as! STSlotCellCollectionViewCell
            cell.columnNum = columnList.count + 1
            cell.rowNum = STTime.periodNum
            cell.ratioForHeader = RatioForHeader
            return cell
        case .Course:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseCell", forIndexPath: indexPath) as! STCourseCellCollectionViewCell
            cell.singleClass = getSingleClass(indexPath)
            cell.lecture = getLecture(indexPath)
            return cell
        case .TemporaryCourse:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseCell", forIndexPath: indexPath) as! STCourseCellCollectionViewCell
            cell.singleClass = getSingleClass(indexPath)
            cell.lecture = getLecture(indexPath)
            return cell
        }
    }
    
    // MARK: UICollectionViewSupplementary
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
