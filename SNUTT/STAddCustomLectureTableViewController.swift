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
        if let timetable = STTimetableManager.sharedInstance.currentTimetable {
            var colorList = STColorManager.sharedInstance.colorList.colorList
            for lecture in timetable.lectureList {
                colorList = colorList.filter({$0 != lecture.color})
            }
            currentLecture.color = colorList.first ?? STColor()
        } else {
            currentLecture.color = STColor()
        }
        
        
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
    
    override func cellTypeAtIndexPath(_ indexPath : IndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0,0): return .title
        case (0,1): return .instructor
        case (0,2): return .color
        case (0,3): return .credit

        case (1,0): return .padding
        case (1,1): return .remark
        case (1,2): return .padding
            
        case (2, currentLecture.classList.count): return .addButton(section: 1)
        case (2, _): return .singleClass

        default: return .padding // Never Reach
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 3
        case 2: return currentLecture.classList.count + 1
        default: return 0 // Never Reached
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! STLectureDetailTableViewCell
        cell.setEditable(true)
        let leftAlignedCell = cell as? STLeftAlignedTableViewCell
        switch cellTypeAtIndexPath(indexPath) {
        case .instructor:
            leftAlignedCell?.textField.placeholder = "예) 홍길동"
        case .title:
            leftAlignedCell?.textField.placeholder = "예) 기초 영어"
        default: break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .color = cellTypeAtIndexPath(indexPath){
            tableView.deselectRow(at: indexPath, animated: true)
            triggerColorPicker()
        } else if case .addButton = cellTypeAtIndexPath(indexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            (self.tableView.cellForRow(at: indexPath) as! STSingleLectureButtonCell).buttonAction?()
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        let ret = STTimetableManager.sharedInstance.addCustomLecture(currentLecture, object: self)
        if case STAddLectureState.success = ret {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            if indexPath.row < currentLecture.classList.count {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentLecture.classList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
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
