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
                self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTimetable(_ title : String, courseBook : STCourseBook) {
        let newTimetable = STTimetable(courseBook: courseBook, title: title)
        timetableList.append(newTimetable)
        reloadList()
        STNetworking.createTimetable(title, courseBook: courseBook, done: { list in
            self.timetableList = list
            self.reloadList()
            }, failure: { _ in
                let index = self.timetableList.index(of: newTimetable)
                self.timetableList.remove(at: index!)
        })
    }
    
    func reloadList() {
        self.sortTimetableList()
        self.tableView.reloadData()
    }
    
    func sortTimetableList() {
        timetableList.sort(by: {a, b in
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
    
    func indexPathToIndex (_ indexPath : IndexPath ) -> Int {
        return indexList[indexPath.section]+indexPath.row
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return indexList.count-1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexList[section+1]-indexList[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTimetableListCell", for: indexPath)
        let timetable = timetableList[indexList[indexPath.section]+indexPath.row]
        cell.textLabel!.text = timetable.title
        if STTimetableManager.sharedInstance.currentTimetable?.id == timetable.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        //configure the cell for loading timetable
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return timetableList[indexList[section]].quarter.longString()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexList[indexPath.section]+indexPath.row
        if timetableList[index].id == nil {
            return
        }
        STNetworking.getTimetable(timetableList[index].id!, done: { timetable in
            if (timetable == nil) {
                STAlertView.showAlert(title: "시간표 로딩 실패", message: "선택한 시간표가 서버에 존재하지 않습니다.")
            }
            STTimetableManager.sharedInstance.currentTimetable = timetable
            tableView.deselectRow(at: indexPath, animated: false)
            self.navigationController?.popViewController(animated: true)
            }, failure: { _ in
                
        })
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPathToIndex(indexPath)
            let timetable = timetableList[index]
            if timetable.id == nil {
                return
            }
            STNetworking.deleteTimetable(timetable.id!, done: {
                self.timetableList.remove(at: index)
                let isSectionDeleted = self.indexList[indexPath.section+1] - self.indexList[indexPath.section] == 1
                self.sortTimetableList()
                if isSectionDeleted {
                    self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                } else {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "STTimetableAddController" {
            ((segue.destination as! UINavigationController).topViewController as! STTimetableAddController).timetableListController = self
        }
    }
    

}
