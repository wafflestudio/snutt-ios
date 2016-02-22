//
//  STSingleLectureTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 23..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STSingleLectureTableViewController: UITableViewController {

    var cellArray : [[UITableViewCell!]] = []
    
    var titleCell : STLeftAlignedTableViewCell!
    var instructorCell : STLeftAlignedTableViewCell!
    var colorCell : STColorPickTableViewCell!
    
    var departmentCell : STSingleLabeledTableViewCell!
    var academicYearAndCreditCell : STDoubleLabeledTableViewCell!
    var classificationAndCategoryCell : STDoubleLabeledTableViewCell!
    var courseNumAndLectureNumCell : STDoubleLabeledTableViewCell!
    
    var singleClassCellList : [STSingleClassTableViewCell!] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCells()
        self.setCellTitles()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        self.tableView.addGestureRecognizer(tapGesture)
    }
    
    func loadCells() {
        titleCell = STLeftAlignedTableViewCell.loadWithOwner(self)
        instructorCell = STLeftAlignedTableViewCell.loadWithOwner(self)
        colorCell = STColorPickTableViewCell.loadWithOwner(self)
        
        departmentCell = STSingleLabeledTableViewCell.loadWithOwner(self)
        academicYearAndCreditCell = STDoubleLabeledTableViewCell.loadWithOwner(self)
        classificationAndCategoryCell = STDoubleLabeledTableViewCell.loadWithOwner(self)
        courseNumAndLectureNumCell = STDoubleLabeledTableViewCell.loadWithOwner(self)
        
        let firstSection : [UITableViewCell!] = [titleCell, instructorCell, colorCell]
        
        let frontPadding = UITableViewCell.init(style: .Default, reuseIdentifier: nil)
        let backPadding = UITableViewCell.init(style: .Default, reuseIdentifier: nil)
        
        let secondSection : [UITableViewCell!] = [frontPadding, departmentCell, academicYearAndCreditCell, classificationAndCategoryCell, courseNumAndLectureNumCell, backPadding]
        
        cellArray = [firstSection,secondSection]
        
    }
    
    func setCellTitles() {
        titleCell.titleLabel.text = "lecture_title".localizedString()
        instructorCell.titleLabel.text = "instructor".localizedString()
        colorCell.titleLabel.text = "color".localizedString()
        
        departmentCell.valueTextField.placeholder = "department".localizedString()
        academicYearAndCreditCell.firstTextField.placeholder = "academic_year".localizedString()
        academicYearAndCreditCell.secondTextField.placeholder = "credit".localizedString()
        classificationAndCategoryCell.firstTextField.placeholder = "classification".localizedString()
        classificationAndCategoryCell.secondTextField.placeholder = "category".localizedString()
        courseNumAndLectureNumCell.firstTextField.placeholder = "course_number".localizedString()
        courseNumAndLectureNumCell.secondTextField.placeholder = "lecture_number".localizedString()
    }
    
    func setInitialLecture(lecture: STLecture) {
        titleCell.textField.text = lecture.title
        instructorCell.textField.text = lecture.instructor
        colorCell.lightColor = FlatBlue()
        colorCell.darkColor = FlatBlueDark()
        
        departmentCell.valueTextField.text = lecture.department
        academicYearAndCreditCell.firstTextField.text = lecture.academicYear
        academicYearAndCreditCell.secondTextField.text = String(lecture.credit) + "학점"
        classificationAndCategoryCell.firstTextField.text = lecture.classification
        classificationAndCategoryCell.secondTextField.text = lecture.category
        courseNumAndLectureNumCell.firstTextField.text = lecture.courseNumber
        courseNumAndLectureNumCell.secondTextField.text = lecture.lectureNumber
        
        for singleClass in lecture.classList {
            let cell = STSingleClassTableViewCell.loadWithOwner(self)
            cell.singleClass = singleClass
            singleClassCellList.append(cell)
        }
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            let editedLecture = getLecture()
            STTimetableManager.sharedInstance.updateLecture(editedLecture)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func getLecture() -> STLecture {
        var ret = STLecture(quarter: STTimetableManager.sharedInstance.currentTimetable!.quarter)
        ret.title = titleCell.textField.text!
        ret.instructor = instructorCell.textField.text!
        //TODO: color
        ret.department = departmentCell.valueTextField.text!
        ret.academicYear = academicYearAndCreditCell.firstTextField.text!
        //ret.credit = academicYearAndCreditCell.secondTextField.text!
        ret.classification = classificationAndCategoryCell.firstTextField.text!
        ret.category = classificationAndCategoryCell.secondTextField.text!
        ret.courseNumber = courseNumAndLectureNumCell.firstTextField.text!
        ret.lectureNumber = courseNumAndLectureNumCell.secondTextField.text!
        ret.classList = singleClassCellList.map({ singleClassCell in
            return singleClassCell.singleClass
        })
        return ret
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < cellArray.count {
            return cellArray[section].count
        }
        return singleClassCellList.count
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section < cellArray.count {
            let cell = cellArray[indexPath.section][indexPath.row]
            return cell
        } else {
            return singleClassCellList[indexPath.row]
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 36
        case 1:
            if indexPath.row == 0 || indexPath.row == cellArray[1].count-1 {
                return 5
            }
            return 42
        case 2:
            return 42
        default:
            //NEVER REACH THIS CODE
            return 36
        }
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        }
        return false
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 2 {
                singleClassCellList.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
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
