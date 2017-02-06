//
//  STTimetableListController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire

class STTimetableListController: UITableViewController {
    
    var timetableList : [STTimetable] = []
    var indexList : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        STNetworking.getTimetableList({ list in
                self.timetableList = list
                self.reloadList()
            }, failure: {
                self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTimetable(title : String, courseBook : STCourseBook) {
        let newTimetable = STTimetable(courseBook: courseBook, title: title)
        timetableList.append(newTimetable)
        reloadList()
        STNetworking.createTimetable(title, courseBook: courseBook, done: { list in
            self.timetableList = list
            self.reloadList()
            }, failure: { _ in
                let index = self.timetableList.indexOf(newTimetable)
                self.timetableList.removeAtIndex(index!)
        })
    }
    
    func reloadList() {
        self.sortTimetableList()
        self.tableView.reloadData()
    }
    
    func sortTimetableList() {
        timetableList.sortInPlace({a, b in
            return a.quarter > b.quarter
        })
        
        indexList = []
        for i in 0..<timetableList.count {
            if(i == 0 || timetableList[i].quarter != timetableList[i-1].quarter) {
                indexList.append(i)
            }
        }
        indexList.append(timetableList.count)
    }
    
    func indexPathToIndex (indexPath : NSIndexPath ) -> Int {
        return indexList[indexPath.section]+indexPath.row
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
        let timetable = timetableList[indexList[indexPath.section]+indexPath.row]
        cell.textLabel!.text = timetable.title
        if STTimetableManager.sharedInstance.currentTimetable?.id == timetable.id {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        //configure the cell for loading timetable
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return timetableList[indexList[section]].quarter.longString()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexList[indexPath.section]+indexPath.row
        if timetableList[index].id == nil {
            return
        }
        STNetworking.getTimetable(timetableList[index].id!, done: { timetable in
            if (timetable == nil) {
                STAlertView.showAlert(title: "시간표 로딩 실패", message: "선택한 시간표가 서버에 존재하지 않습니다.")
            }
            STTimetableManager.sharedInstance.currentTimetable = timetable
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.navigationController?.popViewControllerAnimated(true)
            }, failure: { _ in
                
        })
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let index = indexPathToIndex(indexPath)
        if timetableList[index].isLoaded {
            if STTimetableManager.sharedInstance.currentTimetable?.id == timetableList[index].id  {
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let index = indexPathToIndex(indexPath)
            let timetable = timetableList[index]
            if timetable.id == nil {
                return
            }
            STNetworking.deleteTimetable(timetable.id!, done: {
                self.timetableList.removeAtIndex(index)
                let isSectionDeleted = self.indexList[indexPath.section+1] - self.indexList[indexPath.section] == 1
                self.sortTimetableList()
                if isSectionDeleted {
                    self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                } else {
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }, failure: { _ in
                
            })
            
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "STTimetableAddController" {
            ((segue.destinationViewController as! UINavigationController).topViewController as! STTimetableAddController).timetableListController = self
        }
    }
    

}
