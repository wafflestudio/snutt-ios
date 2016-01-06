//
//  STLectureDetailTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STLectureDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var nameCell: STLectureDetailTableViewCell!
    @IBOutlet weak var professorCell: STLectureDetailTableViewCell!
    @IBOutlet weak var locationCell: STLectureDetailTableViewCell!
    @IBOutlet weak var timeCell: STLectureDetailTableViewCell!
    
    var singleClass : STSingleClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("saveDetail"))
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
        
        nameCell.contentTextField.text = singleClass?.lecture?.name
        professorCell.contentTextField.text = singleClass!.lecture?.professor
        
        locationCell.contentTextField.text = singleClass?.place
        timeCell.contentTextField.text = singleClass?.timeString
        timeCell.contentTextField.enabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("resignFirstResponder"))
        self.tableView.addGestureRecognizer(tapGesture)
    }

    override func resignFirstResponder() -> Bool {
        nameCell.contentTextField.resignFirstResponder()
        professorCell.contentTextField.resignFirstResponder()
        locationCell.contentTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func saveDetail() {
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
