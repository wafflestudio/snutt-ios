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
    
    var timetable : STTimetable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.registerNib(UINib(nibName: "STCourseCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseCell")
        self.collectionView?.registerNib(UINib(nibName: "STColumnHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColumnHeaderCell")
        self.collectionView?.registerNib(UINib(nibName: "STSlotCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SlotCell")
        
        rowList.append("")
        for i in 0..<(STTime.periodNum) {
            let startTime = STTime(day: STTime.STDay.MON, period: i*2)
            let endTime = STTime(day: STTime.STDay.MON, period: i*2+1)
            rowList.append("\(startTime.periodToString()) ~ \(endTime.periodToString())")
        }
        let viewLayout = STTimeTableLayout(aTimetable: timetable)
        self.collectionView?.collectionViewLayout = viewLayout
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
        (self.collectionView?.collectionViewLayout as! STTimeTableLayout).timetable = self.timetable
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
            if timetable == nil {
                return 0
            }
            return timetable!.singleClassList.count
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SlotCell", forIndexPath: indexPath) ;
            return cell
        case .Course:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseCell", forIndexPath: indexPath) as!STCourseCellCollectionViewCell
            cell.singleClass = timetable!.singleClassList[indexPath.row]
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
