//
//  STLectureDetailTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STLectureDetailTableViewController: STSingleLectureTableViewController {
    
    var lecture : STLecture!
    var editable : Bool = false
    
    var editBarButton : UIBarButtonItem!
    var saveBarButton : UIBarButtonItem!
    var cancelBarButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        if lecture.lectureNumber == "" && lecture.courseNumber == "" {
            self.custom = true
        } else {
            self.custom = false
        }
        super.viewDidLoad()
        
        self.currentLecture = lecture
        
        editBarButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(STLectureDetailTableViewController.editBarButtonClicked))
        saveBarButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(STLectureDetailTableViewController.saveBarButtonClicked))
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(STLectureDetailTableViewController.cancelBarButtonClicked))
        
        self.navigationItem.rightBarButtonItem = editBarButton
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !editable {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return
        }
        if case .Color = cellTypeAtIndexPath(indexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            triggerColorPicker()
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    override func cellTypeAtIndexPath(indexPath : NSIndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return .Title
        case (0, 1): return .Instructor
        case (0, 2): return .Color
        case (0, 3): return .Credit
            
        case (1, 0): return .Padding
        case (1, 1): return .Department
        case (1, 2): return .AcademicYearAndCredit
        case (1, 3): return .ClassificationAndCategory
        case (1, 4): return .CourseNumAndLectureNum
        case (1, 5): return .Padding
        
        case (2, currentLecture.classList.count):
            if editable {
                return .AddButton(section: 2)
            }
            return .Padding
        case (2, _): return .SingleClass
            
        case (3, 0):
            if editable {
                return .ResetButton
            } else {
                return .SyllabusButton
            }
            
        default: return .Padding // Never Reach
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return custom ? 3 : 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if custom {
            switch section {
            case 0: return 4
            case 1: return 0
            case 2: return currentLecture.classList.count + ( editable ? 1 : 0)
            default: return 0 // Never Reached
            }
        } else {
            switch section {
            case 0: return 3
            case 1: return 6
            case 2: return currentLecture.classList.count
            case 3: return 1
            default: return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! STLectureDetailTableViewCell
        cell.setEditable(editable)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 2 {
            if indexPath.row < currentLecture.classList.count {
                return custom
            }
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            currentLecture.classList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func editBarButtonClicked() {
        editable = true
        reloadDataWithAnimation()
        self.navigationItem.setRightBarButtonItem(saveBarButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(cancelBarButton, animated: true)
    }
    
    func saveBarButtonClicked() {
        editable = false
        dismissKeyboard()
        reloadDataWithAnimation()
        self.navigationItem.setRightBarButtonItem(editBarButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        let oldLecture = lecture
        lecture = currentLecture
        STTimetableManager.sharedInstance.updateLecture(oldLecture, newLecture: currentLecture)
    }
    
    func cancelBarButtonClicked() {
        editable = false
        dismissKeyboard()
        currentLecture = lecture
        reloadDataWithAnimation()
        self.navigationItem.setRightBarButtonItem(editBarButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
    }
    
    func reloadDataWithAnimation() {
        UIView.transitionWithView(tableView, duration:0.35, options:.TransitionCrossDissolve,
                                  animations: { self.tableView.reloadData() }, completion: nil);
    }
    // MARK: - Table view data source
    

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
