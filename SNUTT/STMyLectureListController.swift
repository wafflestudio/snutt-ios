//
//  STMyLectureListController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class STMyLectureListController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    weak var timetableTabViewController : STTimetableTabViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        self.tableView.registerNib(UINib(nibName: "STLectureTableViewCell", bundle: nil), forCellReuseIdentifier: "LectureCell")
        self.tableView.registerNib(UINib(nibName: "STAddLectureButtonCell", bundle: nil), forCellReuseIdentifier: "AddButtonCell")
        self.tableView.separatorStyle = .None
        self.tableView.rowHeight = 74.0
        
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData:", event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData:", event: STEvent.CurrentTimetableSwitched, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData(notification : NSNotification) {
        if(notification.object === self) {
            return //This is because of delete animation.
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let cnt = STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            return cnt == 0 ? 0 : cnt + 1
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddButtonCell", forIndexPath: indexPath) as! STAddLectureButtonCell
            cell.titleLabel.text = "직접 강좌 추가하기"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LectureCell", forIndexPath: indexPath) as! STLectureTableViewCell
            cell.lecture = STTimetableManager.sharedInstance.currentTimetable?.lectureList[indexPath.row]
            return cell
        }
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            return false
        }
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            STTimetableManager.sharedInstance.deleteLectureAtIndex(indexPath.row, object: self)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.reloadEmptyDataSet()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            self.performSegueWithIdentifier("AddCustomLecture", sender: self)
        } else {
            let detailController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LectureDetailTableViewController") as! STLectureDetailTableViewController
            detailController.lecture = STTimetableManager.sharedInstance.currentTimetable?.lectureList[indexPath.row]
            timetableTabViewController?.navigationController?.pushViewController(detailController, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            return 40.0
        }
        return 74.0
    }
    
    //MARK: DNZEmptyDataSet
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "tabbaritem_timetable")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "시간표에 강좌가 없습니다."
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18.0)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "강좌를 찾아서 넣을수도 있지만, 직접 만들수도 있습니다."
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.systemFontOfSize(14.0),
            NSForegroundColorAttributeName : UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName : paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let text = "직접 만들기"
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(17.0)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.performSegueWithIdentifier("AddCustomLecture", sender: self)
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
