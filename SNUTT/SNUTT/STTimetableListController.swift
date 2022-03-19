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

    struct Section {
        var timetableList : [STTimetable]
        var courseBook : STCourseBook
    }

    var timetableList : [STTimetable] = []
    var sectionList : [Section] = []

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
        }, failure: { 
            let index = self.timetableList.index(of: newTimetable)
            self.timetableList.remove(at: index!)
        })
    }
    
    @objc func reloadList() {
        self.updateSectionedList()
        self.tableView.reloadData()
    }
    
    func updateSectionedList() {
        let courseBookList = STCourseBookList.sharedInstance.courseBookList
        sectionList = courseBookList.map({ courseBook in
            return Section.init(timetableList:
                timetableList.filter({ timetable in
                    timetable.quarter == courseBook.quarter
                }), courseBook: courseBook)
        })
    }

    func getTimetable(from indexPath: IndexPath) -> STTimetable? {
        return sectionList.get(indexPath.section)?.timetableList.get(indexPath.row)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(sectionList[section].timetableList.count, 1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTimetableListCell", for: indexPath)
        if let timetable = getTimetable(from: indexPath) {
            cell.textLabel?.text = timetable.title
            if STTimetableManager.sharedInstance.currentTimetable?.id == timetable.id {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            if timetable.isLoaded {
                cell.textLabel?.textColor = UIColor.black
            } else {
                cell.textLabel?.textColor = UIColor.gray
            }
        } else {
            if sectionList[indexPath.section].timetableList.count == 0 {
                cell.textLabel?.text = "+ 새로운 시간표"
                cell.accessoryType = .none
            }
            cell.textLabel?.textColor = UIColor.gray
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section].courseBook.quarter.longString()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionList[indexPath.section]
        if section.timetableList.count == 0 {
            // create a new timetable and move to that timetable
            addTimetable("시간표 1", courseBook: section.courseBook)
            return
        }
        guard let id = getTimetable(from: indexPath)?.id else {
            return
        }
        STNetworking.getTimetable(id, done: { timetable in
            if (timetable == nil) {
                STAlertView.showAlert(title: "시간표 로딩 실패", message: "선택한 시간표가 서버에 존재하지 않습니다.")
            }
            STTimetableManager.sharedInstance.currentTimetable = timetable
            self.navigationController?.popViewController(animated: true)
        }, failure: { _ in

        })
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let timetable = getTimetable(from: indexPath) else {
            return false
        }
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let timetable = getTimetable(from: indexPath), let id = timetable.id else {
                return
            }
            STNetworking.deleteTimetable(id, done: {
                guard let index = self.timetableList.index(of: timetable) else {
                    return
                }
                let section = self.sectionList.filter({ section in section.timetableList.contains(timetable)})
                self.timetableList.remove(at: index)
                self.updateSectionedList()
                if section.count > 0 && section.first!.timetableList.count > 1 {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }, failure: { 
                
            })
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "STTimetableAddController" {
            ((segue.destination as! UINavigationController).topViewController as! STTimetableAddController).timetableListController = self
        }
    }
    

}
