//
//  STTimetableListController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class STTimetableListController: UITableViewController {
    
    var timetableList : [STTimetable] = []
    var indexList : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(STTimetableRouter.GetTimetableList).responseJSON { response in
            switch response.result {
            case .Success(let value):
                let timetables = JSON(value).arrayValue
                self.timetableList = timetables.map { json in
                    return STTimetable(json: json)
                }
                self.reloadList()
            case .Failure:
                // TODO: alertView about failure
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTimetable(title : String, courseBook : STCourseBook) {
        let newTimetable = STTimetable(year: courseBook.year, semester: courseBook.semester, title: title)
        timetableList.append(newTimetable)
        reloadList()
        Alamofire.request(STTimetableRouter.CreateTimetable(title: title, courseBook: courseBook)).responseJSON { response in
            let index = self.timetableList.indexOf(newTimetable)
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                if json["success"].boolValue {
                    self.timetableList[index!] = STTimetable(json: json["timetable"])
                    self.tableView.reloadData()
                } else {
                    self.timetableList.removeAtIndex(index!)
                }
            case .Failure:
                self.timetableList.removeAtIndex(index!)
                //TODO : alertView about failure
            }
        }
    }
    
    func reloadList() {
        self.sortTimetableList()
        self.tableView.reloadData()
    }
    
    func sortTimetableList() {
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
        
        cell.textLabel!.text = timetableList[
            indexList[indexPath.section]+indexPath.row].title

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return timetableList[indexList[section]].quarterToString()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexList[indexPath.section]+indexPath.row
        STTimetableManager.sharedInstance.currentTimetable = timetableList[index]
        //Do some networking
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.navigationController?.popViewControllerAnimated(true)
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "STTimetableAddController" {
            ((segue.destinationViewController as! UINavigationController).topViewController as! STTimetableAddController).timetableListController = self
        }
    }
    

}
