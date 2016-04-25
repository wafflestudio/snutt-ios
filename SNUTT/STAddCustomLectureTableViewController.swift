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
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        STTimetableManager.sharedInstance.addLecture(currentLecture, object: self)
        self.dismissViewControllerAnimated(true, completion: nil)
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
