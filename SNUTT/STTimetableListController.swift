//
//  STTimetableListController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableListController: UITableViewController {

    var timetableList : [STTimetable] = []
    var indexList : [Int] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        timetableList = [STTimetable(year: 2016, semester: 0,title: "time1"),
            STTimetable(year: 2015, semester: 1,title: "time2"),
            STTimetable(year: 2015, semester: 3,title: "time3")]
        
        timetableList.sortInPlace({a, b in
            if a.year == b.year {
                return a.semester > b.semester
            }
            return a.year > b.year
        })
        indexList = []
        for i in 0..<timetableList.count {
            if(i == 0 || timetableList[i].title != timetableList[i-1].title) {
                indexList.append(i)
            }
        }
        indexList.append(timetableList.count)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addButtonClicked:"))
        
    }

    @IBAction func addButtonClicked() {
        NSLog("NONO")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return indexList.count-1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexList[section+1]-indexList[section]
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STTimetableListCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = timetableList[indexList[indexPath.section]+indexPath.row].title

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return timetableList[indexList[section]].quarterToString()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
