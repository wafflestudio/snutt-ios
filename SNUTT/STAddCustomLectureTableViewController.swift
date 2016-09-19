//
//  STAddCustomLectureTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 23..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STAddCustomLectureTableViewController: STSingleLectureTableViewController {

    override func viewDidLoad() {
        self.custom = true
        currentLecture.color = STColor.colorList[0]
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func cellTypeAtIndexPath(indexPath : NSIndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0,0): return .Title
        case (0,1): return .Instructor
        case (0,2): return .Color
        case (0,3): return .Credit
            
        case (1, currentLecture.classList.count): return .AddButton(section: 1)
        case (1, _): return .SingleClass

        default: return .Padding // Never Reach
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return currentLecture.classList.count + 1
        default: return 0 // Never Reached
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! STLectureDetailTableViewCell
        cell.setEditable(true)
        let leftAlignedCell = cell as? STLeftAlignedTableViewCell
        switch cellTypeAtIndexPath(indexPath) {
        case .Instructor:
            leftAlignedCell?.textField.placeholder = "예) 홍길동"
        case .Title:
            leftAlignedCell?.textField.placeholder = "예) 기초 영어"
        default: break //TODO: Credit selector
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if case .Color = cellTypeAtIndexPath(indexPath){
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            triggerColorPicker()
        } else if case .AddButton = cellTypeAtIndexPath(indexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            (self.tableView.cellForRowAtIndexPath(indexPath) as! STSingleLectureButtonCell).buttonAction?()
        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        let ret = STTimetableManager.sharedInstance.addLecture(currentLecture, object: self)
        if case STAddLectureState.Success = ret {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            if indexPath.row < currentLecture.classList.count {
                return true
            }
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            currentLecture.classList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
