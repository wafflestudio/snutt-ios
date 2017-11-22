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
    var sectionedList : [[STTimetable]] = []

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
        super.viewWillAppear(animated)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CourseBookUpdated, object: nil)
        reloadList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        STEventCenter.sharedInstance.removeObserver(self)
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
        self.updateSectionedList()
        self.tableView.reloadData()
    }
    
    func updateSectionedList() {
        let courseBookList = STCourseBookList.sharedInstance.courseBookList
        sectionedList = courseBookList.map({ courseBook in
            return timetableList.filter({ timetable in
                timetable.quarter == courseBook.quarter
            })
        }).filter({ timetableList in !timetableList.isEmpty})
    }

    func getTimetable(from indexPath: IndexPath) -> STTimetable {
        return sectionedList[indexPath.section][indexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionedList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedList[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTimetableListCell", for: indexPath)
        let timetable = getTimetable(from: indexPath)
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
        return sectionedList[section].first?.quarter.longString() ?? ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = getTimetable(from: indexPath).id else {
            return
        }
        STNetworking.getTimetable(id, done: { timetable in
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
        let timetable = getTimetable(from: indexPath)
        if timetable.isLoaded {
            if STTimetableManager.sharedInstance.currentTimetable?.id == timetable.id  {
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
            let timetable = getTimetable(from: indexPath)
            if timetable.id == nil {
                return
            }
            STNetworking.deleteTimetable(timetable.id!, done: {
                guard let index = self.timetableList.index(of: timetable) else {
                    return
                }
                let section = self.sectionedList.filter({ list in list.contains(timetable)})
                self.timetableList.remove(at: index)
                self.updateSectionedList()
                if section.count > 0 && section.first!.count > 1 {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    self.tableView.reloadData()
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
