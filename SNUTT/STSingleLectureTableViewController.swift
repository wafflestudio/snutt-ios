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
    var creditCell : STLeftAlignedTableViewCell!
    
    var departmentCell : STSingleLabeledTableViewCell!
    var academicYearAndCreditCell : STDoubleLabeledTableViewCell!
    var classificationAndCategoryCell : STDoubleLabeledTableViewCell!
    var courseNumAndLectureNumCell : STDoubleLabeledTableViewCell!
    
    var singleClassCellList : [STSingleClassTableViewCell!] = []
    var custom : Bool = false 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCells()
        self.setCellTitles()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
    }
    
    func loadCells() {
        titleCell = STLeftAlignedTableViewCell.loadWithOwner(self)
        instructorCell = STLeftAlignedTableViewCell.loadWithOwner(self)
        colorCell = STColorPickTableViewCell.loadWithOwner(self)
        creditCell = STLeftAlignedTableViewCell.loadWithOwner(self)

        departmentCell = STSingleLabeledTableViewCell.loadWithOwner(self)
        academicYearAndCreditCell = STDoubleLabeledTableViewCell.loadWithOwner(self)
        classificationAndCategoryCell = STDoubleLabeledTableViewCell.loadWithOwner(self)
        courseNumAndLectureNumCell = STDoubleLabeledTableViewCell.loadWithOwner(self)
        
        var firstSection : [UITableViewCell!]!
        var secondSection : [UITableViewCell!]!
        if custom {
            firstSection = [titleCell, instructorCell, colorCell, creditCell]
            secondSection = []
        } else {
            let frontPadding = UITableViewCell.init(style: .Default, reuseIdentifier: nil)
            let backPadding = UITableViewCell.init(style: .Default, reuseIdentifier: nil)
            
            firstSection = [titleCell, instructorCell, colorCell]
            secondSection = [frontPadding, departmentCell, academicYearAndCreditCell, classificationAndCategoryCell, courseNumAndLectureNumCell, backPadding]
        }
        
        cellArray = [firstSection,secondSection]
        
    }
    
    func setCellTitles() {
        titleCell.titleLabel.text = "lecture_title".localizedString()
        instructorCell.titleLabel.text = "instructor".localizedString()
        colorCell.titleLabel.text = "color".localizedString()
        creditCell.titleLabel.text = "credit".localizedString()
        
        departmentCell.valueTextField.placeholder = "department".localizedString()
        academicYearAndCreditCell.firstTextField.placeholder = "academic_year".localizedString()
        academicYearAndCreditCell.secondTextField.placeholder = "credit".localizedString()
        classificationAndCategoryCell.firstTextField.placeholder = "classification".localizedString()
        classificationAndCategoryCell.secondTextField.placeholder = "category".localizedString()
        courseNumAndLectureNumCell.firstTextField.placeholder = "course_number".localizedString()
        courseNumAndLectureNumCell.secondTextField.placeholder = "lecture_number".localizedString()
    }
    
    func addSingleClass() -> STSingleClassTableViewCell {
        let cell = STSingleClassTableViewCell.loadWithOwner(self)
        singleClassCellList.append(cell)
        if !custom {
            cell.timeTextField.enabled = false
        }
        return cell
    }
    
    func setInitialLecture(lecture: STLecture) {
        titleCell.textField.text = lecture.title
        instructorCell.textField.text = lecture.instructor
        colorCell.color = lecture.color
        
        departmentCell.valueTextField.text = lecture.department
        academicYearAndCreditCell.firstTextField.text = lecture.academicYear
        academicYearAndCreditCell.secondTextField.text = String(lecture.credit) + "학점"
        creditCell.textField.text = String(lecture.credit) + "학점"
        classificationAndCategoryCell.firstTextField.text = lecture.classification
        classificationAndCategoryCell.secondTextField.text = lecture.category
        courseNumAndLectureNumCell.firstTextField.text = lecture.courseNumber
        courseNumAndLectureNumCell.secondTextField.text = lecture.lectureNumber
        
        for singleClass in lecture.classList {
            let cell = self.addSingleClass()
            cell.singleClass = singleClass
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
        ret.color = colorCell.color
        //ret.credit = academicYearAndCreditCell.secondTextField.text!
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath) == colorCell {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            //TODO : Trigger segue for color picker
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("STColorPickerTableViewController") as! STColorPickerTableViewController
            viewController.color = colorCell.color
            viewController.doneBlock = { color in
                self.colorCell.color = color
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
