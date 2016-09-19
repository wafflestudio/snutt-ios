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

    var custom : Bool = false
    var currentLecture : STLecture = STLecture()
    
    enum CellViewType {
        case LeftAligned(title : String)
        case ColorPick
        case SingleLabeled(title : String)
        case DoubleLabeled(firstTitle: String, secondTitle: String)
        case Padding
        case SingleClass
        case Button(title: String, color : UIColor)
        
        var identifier : String {
            switch self {
            case .LeftAligned: return "LeftAlignedCell"
            case .ColorPick: return "ColorPickCell"
            case .SingleLabeled: return "SingleLabeledCell"
            case .DoubleLabeled: return "DoubleLabeledCell"
            case .Padding: return "PaddingCell"
            case .SingleClass: return "SingleClassCell"
            case .Button: return "ButtonCell"
            }
        }
    }
    
    enum CellType {
        case Title
        case Instructor
        case Color
        case Credit
        case Department
        case AcademicYearAndCredit
        case ClassificationAndCategory
        case CourseNumAndLectureNum
        case SingleClass
        case Padding
        case AddButton(section : Int)
        case ResetButton
        case SyllabusButton
        
        var cellViewType : CellViewType {
            switch self {
            case Title: return .LeftAligned(title: "lecture_title".localizedString())
            case Instructor: return .LeftAligned(title: "instructor".localizedString())
            case Color: return .ColorPick
            case Credit: return .LeftAligned(title: "credit".localizedString())
            case Department: return .SingleLabeled(title: "department".localizedString())
            case .AcademicYearAndCredit:
                return .DoubleLabeled(firstTitle: "academic_year".localizedString(), secondTitle: "credit".localizedString())
            case .ClassificationAndCategory:
                return .DoubleLabeled(firstTitle: "classification".localizedString(), secondTitle: "category".localizedString())
            case .CourseNumAndLectureNum:
                return .DoubleLabeled(firstTitle: "course_number".localizedString(), secondTitle: "lecture_number".localizedString())
            case .SingleClass:
                return .SingleClass
            case .Padding:
                return .Padding
            case .AddButton:
                return .Button(title: "Add", color: UIColor.blueColor())
            case .ResetButton:
                return .Button(title: "Reset", color: UIColor.redColor())
            case .SyllabusButton:
                return .Button(title: "Syllabus", color: UIColor.blueColor())
            }
        }
    }
    
    func cellTypeAtIndexPath(indexPath : NSIndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0,0): return .Title
        case (0,1): return .Instructor
        case (0,2): return .Color
        case (0,3): return .Credit
            
        case (1,0): return .Padding
        case (1,1): return .Department
        case (1,2): return .AcademicYearAndCredit
        case (1,3): return .ClassificationAndCategory
        case (1,4): return .CourseNumAndLectureNum
        case (1,5): return .Padding
            
        case (2,_): return .SingleClass
        default: return .Padding // Never Reach
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.registerNib(UINib(nibName: "STSingleLabeledTableViewCell", bundle: NSBundle.mainBundle()),
                              forCellReuseIdentifier: CellViewType.SingleLabeled(title: "").identifier)
        tableView.registerNib(UINib(nibName: "STLeftAlignedTableViewCell", bundle: NSBundle.mainBundle()),
                              forCellReuseIdentifier: CellViewType.LeftAligned(title: "").identifier)
        tableView.registerNib(UINib(nibName: "STColorPickTableViewCell", bundle: NSBundle.mainBundle()),
                              forCellReuseIdentifier: CellViewType.ColorPick.identifier)
        tableView.registerNib(UINib(nibName: "STDoubleLabeledTableViewCell", bundle: NSBundle.mainBundle()),
                              forCellReuseIdentifier: CellViewType.DoubleLabeled(firstTitle: "",secondTitle: "").identifier)
        tableView.registerNib(UINib(nibName: "STSingleClassTableViewCell", bundle: NSBundle.mainBundle()),
                              forCellReuseIdentifier: CellViewType.SingleClass.identifier)
        tableView.registerNib(UINib(nibName: "STSingleLectureButtonCell", bundle: NSBundle.mainBundle()),
                              forCellReuseIdentifier: CellViewType.Button(title: "", color: UIColor.blackColor()).identifier)
        tableView.registerClass(STPaddingTableViewCell.self, forCellReuseIdentifier: CellViewType.Padding.identifier)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(STSingleLectureTableViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if custom {
            switch section {
            case 0: return 4
            case 1: return 0
            case 2: return currentLecture.classList.count
            default: return 0 // Never Reached
            }
        } else {
            switch section {
            case 0: return 3
            case 1: return 6
            case 2: return currentLecture.classList.count
            default: return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let type = cellTypeAtIndexPath(indexPath)
        let cellViewType = type.cellViewType
        let tmpCell = tableView.dequeueReusableCellWithIdentifier(cellViewType.identifier, forIndexPath: indexPath)
        var doneBlock : ((String)->())?
        var timeDoneBlock : ((STTime)->())?
        var actionBlock : (()->())?
        var value1 : String = ""
        var value2 : String = ""
        switch type {
        case .AcademicYearAndCredit:
            value1 = currentLecture.academicYear ??  ""
            value2 = String(currentLecture.credit)
        case .ClassificationAndCategory:
            value1 = currentLecture.classification ?? ""
            value2 = currentLecture.category ?? ""
        case .Color: break
        case .CourseNumAndLectureNum:
            value1 = currentLecture.courseNumber ?? ""
            value2 = currentLecture.lectureNumber ?? ""
        case .Credit:
            value1 = String(currentLecture.credit)
            doneBlock = { value in self.currentLecture.credit = Int(value) ?? 0}
        case .Department:
            value1 = currentLecture.department ?? ""
        case .Instructor:
            value1 = currentLecture.instructor
            doneBlock = { value in self.currentLecture.instructor = value }
        case .Padding: break
        case .SingleClass:
            doneBlock = { value in self.currentLecture.classList[indexPath.row].place = value }
            timeDoneBlock = { value in self.currentLecture.classList[indexPath.row].time = value }
        case .Title:
            value1 = currentLecture.title
            doneBlock = { value in self.currentLecture.title = value }
        case let .AddButton(section):
            actionBlock = { ()->() in
                self.currentLecture.classList.append(STSingleClass(time: STTime(day: 0, startPeriod: 0.0, duration: 1.0), place: ""))
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.currentLecture.classList.count-1, inSection: section)], withRowAnimation: .Automatic);
            }
        case .SyllabusButton:
            actionBlock = { ()->() in
                //TODO: show syllabus
            }
        case .ResetButton:
            actionBlock = { ()->() in
                //TODO: show alert view and reset the values
            }
        }
        
        switch cellViewType {
        case .ColorPick:
            let cell =  tmpCell as! STColorPickTableViewCell
            cell.color = currentLecture.color
            return cell
        case .Padding:
            return tmpCell
        case .SingleClass:
            let cell = tmpCell as! STSingleClassTableViewCell
            cell.singleClass = currentLecture.classList[indexPath.row]
            cell.placeDoneBlock = doneBlock
            cell.timeDoneBlock = timeDoneBlock
            cell.custom = custom
            return cell
        case let .LeftAligned(title):
            let cell = tmpCell as! STLeftAlignedTableViewCell
            cell.titleLabel.text = title
            cell.textField.text = value1
            cell.doneBlock = doneBlock
            return cell
        case let .SingleLabeled(title):
            let cell = tmpCell as! STSingleLabeledTableViewCell
            cell.valueTextField.placeholder = title
            cell.valueTextField.text = value1
            return cell
        case let .DoubleLabeled(firstTitle, secondTitle):
            let cell = tmpCell as! STDoubleLabeledTableViewCell
            cell.firstTextField.placeholder = firstTitle
            cell.secondTextField.placeholder = secondTitle
            cell.firstTextField.text = value1
            cell.secondTextField.text = value2
            return cell
        case let .Button(title, color):
            let cell = tmpCell as! STSingleLectureButtonCell
            cell.buttonAction = actionBlock
            cell.button.tintColor = color
            cell.button.setTitle(title, forState: .Normal)
            cell.button.titleLabel?.text = title
            return cell
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch cellTypeAtIndexPath(indexPath).cellViewType {
        case .LeftAligned: return 36
        case .ColorPick: return 36
        case .DoubleLabeled, .SingleLabeled: return 42
        case .Padding: return 5
        case .SingleClass: return 42
        case .Button: return 36
        }
    }
    
    func triggerColorPicker() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("STColorPickerTableViewController") as! STColorPickerTableViewController
        viewController.color = currentLecture.color
        viewController.doneBlock = { color in
            self.currentLecture.color = color
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(viewController, animated: true)
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
