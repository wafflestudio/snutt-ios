//
//  STTimeTableCollectionViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class STTimeTableCollectionViewController: UICollectionViewController, UIAlertViewDelegate {
    
    var columnList = ["","월", "화", "수", "목", "금", "토"]
    var rowList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        STCourseBooksManager.sharedInstance.timeTableController = self
        
        rowList.append("")
        for i in 0..<(STTime.periodNum) {
            var startTime = STTime(day: STTime.STDay.MON, period: i*2)
            var endTime = STTime(day: STTime.STDay.MON, period: i*2+1)
            rowList.append("\(startTime.periodToString()) ~ \(endTime.periodToString())")
        }

        (self.collectionView?.collectionViewLayout as! STTimeTableLayout).timeTableController = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.dataSource = TimeTableCollectionViewController.datasource
        //TimeTableCollectionViewController.datasource.collectionView = self.collectionView
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.collectionView?.reloadData()
    }
    
    enum cellType{
        case HeaderColumn, HeaderRow, Slot, Course
    }
    
    func getCellType(indexPath : NSIndexPath) -> cellType {
        if indexPath.section == 1 {
            return cellType.Course
        } else {
            if indexPath.row < columnList.count {
                return cellType.HeaderColumn
            } else if indexPath.row % columnList.count == 0 {
                return cellType.HeaderRow
            } else {
                return cellType.Slot
            }
        }
    }
    
    func reloadTimeTable() {
        self.collectionView?.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LectureDetailTableViewController") as! STLectureDetailTableViewController
            detailViewController.singleClass = STCourseBooksManager.sharedInstance.currentCourseBook?.singleClassList[indexPath.row]
            self.showViewController(detailViewController, sender: nil)
        }
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
            return columnList.count * rowList.count
        case 1:
            if STCourseBooksManager.sharedInstance.currentCourseBook == nil {
                return 0
            }
            return STCourseBooksManager.sharedInstance.currentCourseBook!.singleClassList.count
        default:
            return 0
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch getCellType(indexPath) {
        case .HeaderColumn:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColumnHeaderCell", forIndexPath: indexPath) as! STColumnHeaderCollectionViewCell
            cell.contentLabel.text = columnList[indexPath.row]
            return cell
        case .HeaderRow:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColumnHeaderCell", forIndexPath: indexPath) as! STColumnHeaderCollectionViewCell
            cell.contentLabel.text = rowList[indexPath.row / columnList.count]
            return cell
        case .Slot:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SlotCell", forIndexPath: indexPath) as! UICollectionViewCell;
            return cell
        case .Course:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseCell", forIndexPath: indexPath) as!STCourseCellCollectionViewCell
            cell.singleClass = STCourseBooksManager.sharedInstance.currentCourseBook?.singleClassList[indexPath.row]
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
